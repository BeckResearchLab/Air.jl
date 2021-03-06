using Air
using Test
using Random.Random

@testset "Air.jl" begin

    #@testset "PArray" begin
    #    numops = 100
    #    @testset "1D" begin
    #        a = Real[]
    #        p = Air.PVector{Real}()
    #        ops = [:push, :pushfirst, :pop, :popfirst, :set, :get]
    #        for ii in 1:numops
    #            q = rand(ops)
    #            if q == :push
    #                x = rand(Float64)
    #                push!(a, x)
    #                p = Air.push(p, x)
    #            elseif q == :pop && length(a) > 0
    #                x = pop!(a)
    #                @test x == p[end]
    #                p = Air.pop(p)
    #            elseif q == :pushfirst
    #                x = rand(Float64)
    #                pushfirst!(a, x)
    #                p = Air.pushfirst(p, x)
    #            elseif q == :popfirst && length(a) > 0
    #                x = popfirst!(a)
    #                @test x == p[1]
    #                p = Air.popfirst(p)
    #            elseif q == :set && length(a) > 0
    #                k = rand(1:length(a))
    #                v = rand(Float64)
    #                a[k] = v
    #                p = Air.setindex(p, v, k)
    #            elseif q == :get && length(a) > 0
    #                k = rand(1:length(a))
    #                @test a[k] == p[k]
    #            end
    #            @test a == p
    #            @test size(a) == size(p)
    #        end
    #    end
    #    #@testset "2D" begin
    #    #end
    #    #@testset "3D" begin
    #    #end
    #end

    # #PSet ####################################################################
    function compare_test(p::SIMM, s::SMUT, ks::Vector{T}, n::Int) where {T,SIMM<:AbstractSet{T},SMUT<:AbstractSet{T}}
        let k, q, pd = [:push, :delete], ks = collect(ks)
            for i in 1:n
                k = rand(ks)
                q = rand(pd)
                if q == :push
                    p = Air.push(p, k)
                    push!(s, k)
                else
                    p = Air.delete(p, k)
                    delete!(s, k)
                end
                @test length(p) == length(s)
                @test (k in p) == (k in s)
                @test isequal(p, s)
            end
        end
    end
    @testset "PSet" begin
        # First, do a standard test:
        numops = 100
        numits = 10
        for it in 1:numits
            mut = Set{Real}()
            imm = Air.PSet{Real}()
            ops = [:push, :pop, :get]
            for ii in 1:numops
                q = rand(ops)
                if q == :push
                    x = rand(Float64)
                    push!(mut, x)
                    imm = Air.push(imm, x)
                elseif q == :pop && length(mut) > 0
                    x = rand(mut)
                    delete!(mut, x)
                    imm = Air.delete(imm, x)
                elseif q == :get && length(mut) > 0
                    x = rand(mut)
                    @test in(x, imm)
                end
                @test length(mut) == length(imm)
                @test mut == imm
            end
        end
        # Next, using the above function
        let syms = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j], n = 100
            @testset "PIdSet" begin
                compare_test(Air.PIdSet{Symbol}(), Base.IdSet{Symbol}(), syms, n)
                compare_test(Air.PIdSet{Symbol}([:b, :d, :e]), Base.IdSet{Symbol}([:b, :d, :e]), syms, n)
            end
            @testset "PSet" begin
                compare_test(Air.PSet{Symbol}(), Air.EquivSet{Symbol}(), syms, n)
                compare_test(Air.PSet{Symbol}([:b, :d, :e]), Air.EquivSet{Symbol}([:b, :d, :e]), syms, n)
            end
            @testset "PEqualSet" begin
                compare_test(Air.PEqualSet{Symbol}(), Set{Symbol}(), syms, n)
                compare_test(Air.PEqualSet{Symbol}([:b, :d, :e]), Set{Symbol}([:b, :d, :e]), syms, n)
            end
        end
    end

    # #PSet ####################################################################
    function compare_test(
        p::DIMM, s::DMUT, ks::Vector{K}, vs::Vector{V}, n::Int
    ) where {K,V, DIMM <: AbstractDict{K,V}, DMUT <: AbstractDict{K,V}}
        pd = [:set, :delete, :get]
        for i in 1:n
            q = rand(pd)
            if q == :set
                k = rand(ks)
                v = rand(vs)
                p = Air.push(p, k => v)
                push!(s, k => v)
            elseif q == :delete && length(s) > 0
                k = rand(keys(s))
                p = Air.delete(p, k)
                delete!(s, k)
            else
                k = rand(ks)
            end
            @test isequal(p, s)
            @test length(p) == length(s)
            @test get(p, k, nothing) == get(s, k, nothing)
            @test ((k => get(p, k, nothing)) in p) == ((k => get(s, k, nothing)) in s)
        end
    end
    @testset "PDict" begin
        # Next, using the above function
        syms = Symbol[:a, :b, :c, :d, :e, :f, :g, :h, :i, :j]
        nums = Real[10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        n = 100
        @testset "PIdDict" begin
            compare_test(Air.PIdDict{Symbol,Real}(),
                         Base.IdDict{Symbol,Real}(),
                         syms, nums, n)
            compare_test(Air.PIdDict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         Base.IdDict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         syms, nums, n)
        end
        @testset "PDict" begin
            compare_test(Air.PDict{Symbol,Real}(),
                         Air.EquivDict{Symbol,Real}(),
                         syms, nums, n)
            compare_test(Air.PDict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         Air.EquivDict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         syms, nums, n)
        end
        @testset "PEqualDict" begin
            compare_test(Air.PEqualDict{Symbol,Real}(),
                         Base.Dict{Symbol,Real}(),
                         syms, nums, n)
            compare_test(Air.PEqualDict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         Base.Dict{Symbol,Real}(:b=>20, :d=>40, :e=>50),
                         syms, nums, n)
        end
    end
end
