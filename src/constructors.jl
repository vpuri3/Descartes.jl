function Square(dims;center=false)
    @assert length(dims) == 2
    lb = SVector(0.,0.)
    center && (lb = -SVector{2,Float64}(dims)/2)
    Square(SVector{2,Float64}(dims), lb, SMatrix{3,3}(1.0*I), SMatrix{3,3}(1.0*I))
end


function Cuboid(dims;center=false)
    @assert length(dims) == 3
    lb = SVector(0.,0.,0.)
    center && (lb = -SVector{3,Float64}(dims)/2)
    Cuboid(SVector{3,Float64}(dims), lb, SMatrix{4,4}(1.0*I), SMatrix{4,4}(1.0*I))
end

#= function RoundedCuboid{T}(dims::Vector{T},axes::Vector{Bool},r)
    @assert length(dims) == 3
    RoundedCuboid(dims, axes, convert(T,r), eye(4), eye(4))
end =#

function Cylinder(r, h; center=false)
    rn, hn = Float64(r), Float64(h)
    b = 0.0
    center && (b = -h/2)
    Cylinder(rn, hn, b, SMatrix{4,4}(one(rn)*I), SMatrix{4,4}(one(rn)*I))
end

function Sphere(r)
    Sphere(Float64(r), SMatrix{4,4}(1.0*I), SMatrix{4,4}(1.0*I))
end

#function PrismaticCylinder(sides, height::T, radius::T) where {T}
#    PrismaticCylinder(sides, height, radius, Matrix(1.0*I,4,4), Matrix(1.0*I,4,4))
#end

function Piping(r, pts)
    ptsc = [SVector{3,Float64}(pt...) for pt in pts]
    Piping(Float64(r), ptsc, SMatrix{4,4}(1.0*I), SMatrix{4,4}(1.0*I))
end

# CSG

# Union
function CSGUnion(l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return CSGUnion{N1,T1, typeof(l), typeof(r)}(l,r)
end

function CSGUnion(l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}...) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return CSGUnion(l,CSGUnion(r[1], r[2:end]...))
end

CSGUnion(x::AbstractPrimitive) = x
CSGUnion(::Nothing, x::AbstractPrimitive) = x
CSGUnion(x::AbstractPrimitive, ::Nothing) = x


# Radiused Union
function RadiusedCSGUnion(radius::Real, l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return RadiusedCSGUnion{N1,T1, typeof(l), typeof(r)}(radius,l,r)
end

# diff
function CSGDiff(l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return CSGDiff{N1,T1, typeof(l), typeof(r)}(l,r)
end

function CSGDiff(l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}...) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return CSGDiff(l,CSGUnion(r[1], r[2:end]...))
end

CSGDiff(x::AbstractPrimitive) = x
CSGDiff(::Nothing, x::AbstractPrimitive) = x
CSGDiff(x::AbstractPrimitive, ::Nothing) = x


function CSGIntersect(l::AbstractPrimitive{N1,T1}, r::AbstractPrimitive{N2,T2}) where {N1, N2, T1, T2}
    N1 == N2 || error("cannot create CSG between objects in R$N1 and R$N2")
    return CSGIntersect{N1,T1, typeof(l), typeof(r)}(l,r)
end

CSGIntersect(x::AbstractPrimitive) = x
CSGIntersect(::Nothing, x::AbstractPrimitive) = x
CSGIntersect(x::AbstractPrimitive, ::Nothing) = x

# Shell

function Shell(r)
    Shell(nothing, r)
end
