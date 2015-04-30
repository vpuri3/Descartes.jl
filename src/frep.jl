# http://en.wikipedia.org/wiki/Function_representation

@inline function FRep(p::Sphere, _x, _y, _z)
    it = p.inv_transform
    @inbounds x = _x*it[1,1]+_y*it[1,2]+_z*it[1,3]+it[1,4]
    @inbounds y = _x*it[2,1]+_y*it[2,2]+_z*it[2,3]+it[2,4]
    @inbounds z = _x*it[3,1]+_y*it[3,2]+_z*it[3,3]+it[3,4]
    sqrt(x*x + y*y + z*z) - p.radius
end

@inline function FRep(p::Cylinder, _x, _y, _z)
    it = p.inv_transform
    @inbounds x = _x*it[1,1]+_y*it[1,2]+_z*it[1,3]+it[1,4]
    @inbounds y = _x*it[2,1]+_y*it[2,2]+_z*it[2,3]+it[2,4]
    @inbounds z = _x*it[3,1]+_y*it[3,2]+_z*it[3,3]+it[3,4]
    max(max(-z,z-p.height), sqrt(x*x + y*y) - p.radius)
end

@inline function FRep(p::Cuboid, _x, _y, _z)
    it = p.inv_transform
    @inbounds x = _x*it[1,1]+_y*it[1,2]+_z*it[1,3]+it[1,4]
    @inbounds y = _x*it[2,1]+_y*it[2,2]+_z*it[2,3]+it[2,4]
    @inbounds z = _x*it[3,1]+_y*it[3,2]+_z*it[3,3]+it[3,4]
    max(max(-x, x-p.dimensions[1]),
        max(-y, y-p.dimensions[2]),
        max(-z, z-p.dimensions[3]))
end

@inline function FRep(p::PrismaticCylinder, _x, _y, _z)
    # http://math.stackexchange.com/questions/41940/is-there-an-equation-to-describe-regular-polygons
    it = p.inv_transform
    @inbounds x = _x*it[1,1]+_y*it[1,2]+_z*it[1,3]+it[1,4]
    @inbounds y = _x*it[2,1]+_y*it[2,2]+_z*it[2,3]+it[2,4]
    @inbounds z = _x*it[3,1]+_y*it[3,2]+_z*it[3,3]+it[3,4]
    sn = sin(pi/p.sides)
    cn = cos(pi/p.sides)
    r = p.radius
    b = max(max(r*sn, max(-y, y-r)),max(r*sn,max(-y, y-r)),(x-r*cn))
    max(max(-z, z-p.height), b)
end

@inline function FRep(u::CSGUnion, x, y, z)
    min(FRep(u.left, x,y,z),FRep(u.right, x,y,z))
end

@inline function FRep(u::CSGDiff, x, y, z)
    max(FRep(u.left, x,y,z), -FRep(u.right, x,y,z))
end

@inline function FRep(u::CSGIntersect, x, y, z)
    max(FRep(u.left, x,y,z), FRep(u.right, x,y,z))
end

@inline function FRep(u::RadiusedCSGUnion, x, y, z)
    a = FRep(u.left, x,y,z)
    b = FRep(u.right, x,y,z)
    r = u.radius
    if abs(a-b) >= r
        return min(a,b)
    else
        return b+r*sin(pi/4+asin((a-b)/(r*sqrt(2))))-r
    end
end
