module LIPO

using LinearAlgebra

function lipo(f; k=0.0, n = 100, lower=0.0, upper=2.0, max_ndraws=1e4)
    Xdom = [0.0, upper]

    X = [rand()*(upper-lower)+lower]
    fX = [f(X[1])]

    U(Xtp1, X, fX, k) = minimum(fXt+k*norm(Xtp1 - Xt, 2) for (Xt, fXt) in zip(X, fX))
    t = 1
    ndraws = 0
    while t < n
       Xtp1 = rand()*(upper-lower)+lower
       ndraws += 1
       if U(Xtp1, X, fX, k) >= maximum(fX)
           X = push!(X, Xtp1)
           fX = push!(fX, f(X[end]))
           t += 1
       end
       if ndraws >= max_ndraws
           break
       end
    end
    return X, fX, ndraws
end


function adalipo(f; k_α=0.5, n = 100, lower=0.0, upper=2.0, max_ndraws=1e4, choose_max=true)
    Xdom = [lower, upper]

    # first, check that function isn't constant, run for max
    # safeguarding number of iterations (used to ensure a proper)

    X = [rand()*(upper-lower)+lower]
    fX = [f(X[1])]

    U(Xtp1, X, fX, k) = minimum(fXt+k*norm(Xtp1-Xt, 2) for (Xt, fXt) in zip(X, fX))
    t = 1
    ndraws = 0
    nexploit = 0
    nexplore = 0
    p = 0.4
    khat_i = 0.0
    while t < n
        if rand() < p
            Xtp1 = rand()*(upper-lower)+lower
            nexplore += 1
        else
            Xtp1 = exploit(fX, X, khat_i, choose_max, lower, upper)
            nexploit += 1
        end

       # a draw can come from
       ndraws += 1
       if U(Xtp1, X, fX, khat_i) >= maximum(fX)
           X = push!(X, Xtp1)
           fX = push!(fX, f(X[end]))
           t += 1
       end

       khat_i = khat(k_α, fX, X)

       if ndraws >= max_ndraws
           break
       end

    end
    return X, fX, ndraws
end


function exploit(fX, X, khat_i, choose_max, lower, upper)
    # pick either the largest or from the set of
    # tops
    val_at_tops, x_at_tops = find_tops(fX, X, khat_i, l)
    if chose_max
        i_m = argmax(val_at_tops)
    else
        i_m = rand(val_at_tops)
    end
    Xtp1 = x_at_tops[i_m]
end

function find_tops(fX, X, khat_i, lower, upper)
    xperm = sortperm(X)
    x = X[xperm]
    f = fX[perm]
    if f[1]+norm(x) < f[end]
        x_top = f[end]
        f_top = f[end]
    else
        x_top = x[1]
        f_top = f[1]
    end

    x_top = 0.0
    val_top = NaN
    for 1:length(x)-1
        if norm(x[i]-x[i+1])
    end
end

function khat(k_α, fX::AbstractVector{T}, X; max_depth = 100) where T
    #find estimates

    argmax_val = -T(1)
    for j = 1:length(X)
        for i = 1:length(X)
            if i == j
                continue
            end
            num = abs(fX[i] - fX[j])
            den = norm(X[i]- X[j], 2)
            candidate = num/den
            if candidate > argmax_val
                argmax_val = candidate
            end
        end
    end

    # Using the cloesd form solution in the paper
    k_i = ceil(log(argmax_val)/log(1+k_α))
    k_i
end

end # module
