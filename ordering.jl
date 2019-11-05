module Ordering


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


end
