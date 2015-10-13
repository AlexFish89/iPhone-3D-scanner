#include "Vector3DEx.h"
#include <math.h>

Vector3DEx::Vector3DEx(void):vectorLength(0)
{
}

Vector3DEx::Vector3DEx(const Vector3D& other):Vector3D(other)
{
    vectorLength = sqrtf(_x*_x + _y*_y + _z*_z);
}

Vector3DEx::Vector3DEx(double x,double y,double z) : Vector3D(x,y,z)
{
	vectorLength = sqrtf(_x*_x + _y*_y + _z*_z);
}

Vector3DEx::~Vector3DEx(void)
{
}

double Vector3DEx::angle(Vector3DEx& other)
{
	double cosAngle = (*this*other)/(length()*other.length());
	double ang = acosf(cosAngle);
	return ang;
}
double Vector3DEx::length()
{
	return vectorLength;
}
Vector3DEx Vector3DEx::normalize()
{
	double vecMag = length();
	if ( vecMag == 0.0 )
	{
		return Vector3DEx(1.0,0,0);
	}
	return Vector3DEx(_x /= vecMag,_y /= vecMag,_z /= vecMag);
}
Vector3DEx Vector3DEx::crossProduct(Vector3DEx& other)
{
	Vector3DEx ret;
	ret._x = (_y * other._z) - (_z * other._y);
	ret._y = (_z * other._x) - (_x * other._z);
	ret._z = (_x * other._y) - (_y * other._x);
	return ret;
}

Vector3DEx& Vector3DEx::operator +=(const Vector3DEx& other)
{
    _x += other._x;
    _y += other._y;
    _z += other._z;
    return *this;
}

Vector3DEx& Vector3DEx::operator -=(const Vector3DEx& other)
{
    _x -= other._x;
    _y -= other._y;
    _z -= other._z;
    return *this;
}

Vector3DEx& Vector3DEx::operator *=(double alpha)
{
    _x *= alpha;
    _y *= alpha;
    _z *= alpha;
    return *this;

}

bool	 Vector3DEx::operator <(const Vector3DEx & other) const
{
	if(_x > other._x)
	{
		return false;
	}
	if(_x == other._x)
	{
		if(_y > other._y)
		{
			return false;
		}
		if(_y == other._y)
		{
			if(_z >= other._z)
			{
				return false;
			}
		}
	}
	return true;
}
bool	 Vector3DEx::operator ==(const Vector3DEx & other) const
{
	return _x == other._x && _y == other._y && _z == other._z;
}
bool	 Vector3DEx::operator !=(const Vector3DEx & other) const
{
	return !(*this == other);
}
bool     Vector3DEx::operator > (const Vector3DEx & other) const
{
	return (*this != other) && !(*this < other);
}
	
Vector3DEx Vector3DEx::operator - (const Vector3DEx & other) const
{
	Vector3DEx diff;
	diff._x = _x - other._x;
	diff._y = _y - other._y;
	diff._z = _z - other._z;
	return diff;
}
Vector3DEx Vector3DEx::operator + (const Vector3DEx & other) const
{
	Vector3DEx sum;
	sum._x = _x + other._x;
	sum._y = _y + other._y;
	sum._z = _z + other._z;
	return sum;
}

double	 Vector3DEx::operator	* (const Vector3DEx & other) const
{
	double dot = _x*other._x + _y*other._y + _z*other._z;
	return dot;
}
Vector3DEx Vector3DEx::operator * (double alpha) const
{
	return Vector3DEx(_x * alpha , _y * alpha , _z * alpha);
}

double Vector3DEx::operator [] (int target) const {
    switch (target) {
        case 0:
            return this->Vector3D::getX();
            break;
        case 1:
            return this->Vector3D::getY();
            break;
        case 2:
            return this->Vector3D::getZ();
            break;
        default:                            //maybe need to throw exception.
            break;
    }
    return this->Vector3D::getX();
}

double Vector3DEx::getX()
{
	return _x;
}

double Vector3DEx::getY()
{
	return _y;
}

double Vector3DEx::getZ()
{
	return _z;
}
