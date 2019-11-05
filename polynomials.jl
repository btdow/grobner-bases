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

# Pretty Printing, Operator Overloading
function Base.show(io::IO, m::Monomial)
    for (i, e) in enumerate(m.exponents)
        if e > 0
            print(io, "x$(i)")
        end
        if e > 1
            print(io, "^$(e)")
        end
    end
end

function Base.show(io::IO, t::Term)
    if t.coefficient > 0
        print(io, " + ")
    else
        print(io, " - ")
    end
    print(io, "$(abs(t.coefficient))")
    print(io, t.monomial)
end

function Base.show(io::IO, p::Polynomial)
    for t in p.terms
        print(io, t)
    end
end

function Base.:+(p1::Polynomial, p2::Polynomial)
end
    
function Base.:-(p1::Polynomial, p2::Polynomial)
end

function Base.:*(p1::Polynomial, p2::Polynomial)
end

function Base.:/(p1::Polynomial, p2::Polynomial)
end

function Base.:+(t::Term, p::Polynomial)
end

function Base.:+(p::Polynomial, t::Term)
end

function Base.:-(t::Term, p::Polynomial)
end

function Base.:-(p::Polynomial, t::Term)
end

function Base.:*(t::Term, p::Polynomial)
end

function Base.:*(p::Polynomial, t::Term)
end

function Base.:/(p::Polynomial, t::Term)
end

function Base.:+(t1::Term, t2::Term)
    if exponents(t1) == exponents(t2)
        return Term(coeff(t1) + coeff(t2), monom(t1))
    else
        return Polynomial([t1, t2])
    end
end

function Base.:-(t1::Term, t2::Term)
    if exponents(t1) == exponents(t2)
        return Term(coeff(t1) - coeff(t2), monom(t1))
    else
        return Polynomial([t1, Term(-coeff(t2), monom(t2))])
    end
end

function Base.:*(t1::Term, t2::Term)
    return Term(coeff(t1) * coeff(t2), monom(t1) * monom(t2))
end

function Base.:/(t1::Term, t2::Term)
    if coeff(t2) != 0
        return Term(coeff(t1) / coeff(t2), monom(t1) / monom(t2))
    else
        error("coeff division by zero")
    end
end

function Base.:*(m1::Monomial, m2::Monomial)
    Monomial([m1.exponents[i] + m2.exponents[i]
              for i in 1:length(m1.exponents)
              if length(m1.exponents) == length(m2.exponents)])
end

function Base.:/(m1::Monomial, m2::Monomial)
    if monom_divides(m1, m2)
        return Monomial([m1.exponents[i] - m2.exponents[i]
                         for i in 1:length(m1.exponents)
                         if length(m1.exponents) == length(m2.exponents)])
    else
        error("$(m2) does not divide $(m1)")
    end
end

function Base.:/(m::Monomial, t::Term)
    if monom_divides(m, t.monomial)
        if coeff(t) != 0
            return Term(1 / t.coefficient, m / t.monomial)
        else
            error("division by zero")
        end
    else
        error("$(t) does not divide $(m)")
    end
end

# Utility Functions
coeff(t::Term) = t.coefficient
monom(t::Term) = t.monomial
monom(m::Monomial) = m
term(t::Term) = t
poly(p::Polynomial) = p
exponents(t::Term) = t.monomial.exponents
exponents(m::Monomial) = m.exponents
deg(t::Term) = t.monomial.degree
deg(m::Monomial) = m.degree
deg(p::Polynomial) = p.degree
coefficients(p::Polynomial) = [coeff(t) for t in p.terms]
monomials(p::Polynomial) = [monom(t) for t in p.terms]
terms(p::Polynomial) = p.terms
LT(p::Polynomial) = p.terms[1]
LM(p::Polynomial) = monom(p.terms[1])
LC(p::Polynomial) = coeff(p.terms[1])
LCM(m1::Monomial, m2::Monomial) = Monomial([max(m1.exponents[i],
                                                m2.exponents[i])
                                            for i in 1:length(m1.exponents)])

function monom_divides(m1, m2)
    for i in 1:length(m1.exponents)
        if (m1.exponents[i] - m2.exponents[i]) < 0
            return false
        end
    end
    return true
end 

function order_polynomial(t::Array, order=:lex)
    # order an array of terms, default lex.
    # This should not be a public function
    if order == :lex
        return sort(t, lt=lex)
    elseif order == :rlex
        return sort(t, lt=rlex)
    elseif order == :grlex
        return sort(t, lt=grlex)
    elseif order == :grevlex
        return sort(t, lt=grevlex)
    else
        error("order_polynomial(): invalid ordering")
    end
end

function reorder_polynomial(p::Polynomial, order=:lex)
    # Reorder a polynomial
    if p.order == order
        return p
    else
        return Polynomial(p.terms, order)
    end
end
        
function maxdegree(terms::Array)
    # Find max degree for lex/rlex orders
    max = 0
    for t in terms
        if max < deg(t)
            max = deg(t)
        end
    end
    return max
end

# Ordering functions
# Ordering should be set globally by the output of the parser.

function lex_cmp(multideg, order=:lex)
    # Lexicographic ordering test
    # Forward Lex: Leftmost nonzero positive
    # Reverse Lex: Rightmost nonzero negative
    if order == :lex || order == :grlex
        for i in multideg
            if i == 0
                continue
            elseif i > 0
                return true
            else
                return false
            end
        end
    elseif order == :rlex
        for i in reverse(multideg)
            if i == 0
                continue
            elseif i > 0
                return true
            else
                return false
            end
        end
    elseif order == :grevlex
        for i in reverse(multideg)
            if i == 0
                continue
            elseif i < 0
                return true
            else
                return false
            end
        end
    else
        error("lex_cmp(): invalid ordering")
    end
end

function graded_cmp(t1, t2)
    # Graded ordering test
    # Is term1 greater than term2?
    if deg(t1) > deg(t2)
        return true
    elseif deg(t1) < deg(t2)
        return false
    else
        return -1
    end
end

function order_cmp(t1, t2, order=:lex)
    # Ordering key for sorting monomials
    if order == :lex
        return lex_cmp(exponents(t1) - exponents(t2), order)
    elseif order == :rlex
        return lex_cmp(exponents(t1) - exponents(t2), order)
    elseif order == :grlex
        res = graded_cmp(t1, t2)
        if res == -1
            return lex_cmp(exponents(t1) - exponents(t2), order)
        else
            return res
        end
    elseif order == :grevlex
        res = graded_cmp(t1, t2)
        if res == -1
            return lex_cmp(exponents(t1) - exponents(t2), order)
        else
            return res
        end
    else
        error("order_cmp(): invalid ordering")
    end
end

function lex(t1::Term, t2::Term)
    order_cmp(t1, t2, :lex)
end

function rlex(t1::Term, t2::Term)
    order_cmp(t1, t2, :rlex)
end

function grlex(t1::Term, t2::Term)
    order_cmp(t1, t2, :grlex)
end

function grevlex(t1::Term, t2::Term)
    order_cmp(t1, t2, :grevlex)
end


#= 

PARSING

RULES: 
Coefficients can be Ints or Floats (possibly rationals?)
You can have one constant term in the last position only.

=#

function parse_poly_from_string(pstring, nvars, order=:lex)
    poly_arr = []
    monom = zeros(nvars)
    coeff = 0

    pattern = r"((([+-]?\d*(?:[./]\d*)?)?(?:[+-\\*]?x(\d+)(?:\^(\d+))?)))?|([+-]\d+(?:[./]\d*)?)"
    match_iterator = eachmatch(pattern, pstring)

    for (i, m) in enumerate(match_iterator)
        if i == 1
            if m.captures[6] != nothing
                coeff = parse(Float64, m.captures[6])
                push!(poly_arr, Term(coeff, Monomial(monom)))               
            elseif m.captures[3] != nothing
                if m.captures[3] == "+"
                    coeff = 1.0
                elseif m.captures[3] == "-"
                    coeff = -1.0
                elseif m.captures[3] == ""
                    coeff = 1.0
                else
                    coeff = parse(Float64, m.captures[3])
                end
                if m.captures[5] == nothing
                    monom[parse(Int, m.captures[4])] = 1
                else
                    monom[parse(Int, m.captures[4])] = parse(Int, m.captures[5])
                end
            else
                error("malformed input")
            end
            continue          
        else
            if m.captures[6] != nothing
                push!(poly_arr, Term(coeff, Monomial(monom)))
                coeff = parse(Float64, m.captures[6])
                monom = zeros(nvars)
                break
            else
                if m.captures[3] != nothing
                    if m.captures[3] == ""
                        if m.captures[5] == nothing
                            monom[parse(Int, m.captures[4])] = 1
                            continue
                        else
                            monom[parse(Int, m.captures[4])] = parse(Int, m.captures[5])
                            continue
                        end
                    else
                        push!(poly_arr, Term(coeff, Monomial(monom)))
                        monom = zeros(nvars)
                        if m.captures[3] == "+"
                            coeff = 1.0
                        elseif m.captures[3] == "-"
                            coeff = -1.0
                        else
                            coeff = parse(Float64, m.captures[3])
                        end
                        if m.captures[5] == nothing
                            monom[parse(Int, m.captures[4])] = 1
                            continue
                        else
                            monom[parse(Int, m.captures[4])] = parse(Int, m.captures[5])
                            continue
                        end
                    end
                end
            end
        end
    end
    push!(poly_arr, Term(coeff, Monomial(monom)))
    return Polynomial(poly_arr, order)
end
