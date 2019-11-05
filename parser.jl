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
