module Types


struct Monomial
    exponents::Array{Int}
    degree::Int

    function Monomial(m)
        total = 0
        for i in m
            if i < 0
                error("no negative numbers")
            end
            total += i
        end
        new(m, total)
    end
end

struct Term
    coefficient::Number
    monomial::Monomial
    constant::Bool

    function Term(c, m)
        if c == 0
            return 0
        end
        if m.degree == 0
            constant = true
        else
            constant = false
        end
        new(c, m, constant)
    end
end

struct Polynomial
    terms::Array
    degree::Int
    order::Symbol

    function Polynomial(t, order=:lex)
        degree = maxdegree(t)
        terms = order_polynomial(t, order)
        new(terms, degree, order)
    end
end

struct PolynomialSystem
    polynomials::Array{Polynomial}
    degree::Int
end

struct PolynomialRing
    variables::Array
    field::Symbol
end

mutable struct Signature
    monomial::Monomial
    index::Int
end

struct LabeledPolynomial
    signature::Signature
    polynomial::Polynomial
    index::Int
end

struct CriticalPair
    lcm_degree::Int
    t::Term
    u::Term
    k::Int
    v::Term
    l::Int
end


end