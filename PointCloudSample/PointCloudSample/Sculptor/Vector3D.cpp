#include "Vector3D.h"
//#include <sstream>

Vector3D::Vector3D(){}

Vector3D::Vector3D(const Vector3D& other): _x(other._x), _y(other._y), _z(other._z)
{
}


Vector3D::Vector3D(double x,double y,double z): _x(x),_y(y),_z(z)
{
}

Vector3D Vector3D::operator + (const Vector3D & other) const
{
	Vector3D xyz;
	xyz._x = _x+other._x;
	xyz._y = _y+other._y;
	xyz._z = _z+other._z;
	return xyz;
}

Vector3D Vector3D::operator * (double alpha) const
{
	return Vector3D(_x*alpha,_y*alpha,_z*alpha);
}


Vector3D& Vector3D::operator +=(const Vector3D& other)
{
    _x += other._x;
    _y += other._y;
    _z += other._z;
    return *this;
}

Vector3D& Vector3D::operator -=(const Vector3D& other)
{
    _x -= other._x;
    _y -= other._y;
    _z -= other._z;
    return *this;
}

Vector3D& Vector3D::operator *=(double alpha)
{
    _x *= alpha;
    _y *= alpha;
    _z *= alpha;
    return *this;
    
}

Vector3D& Vector3D::operator /=(double alpha)
{
    _x /= alpha;
    _y /= alpha;
    _z /= alpha;
    return *this;
    
}
//ofstream& operator<<(ofstream &stream, Vector3D vec)
//{
//    stringstream x,y,z;
//    x << vec._x;
//    y << vec._y;
//    z << vec._z;
//    
//    stream << x.str() << " " << y.str() << z.str() << " ";
//    
//    return stream;
//}

