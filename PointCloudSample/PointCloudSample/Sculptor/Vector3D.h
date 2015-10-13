#pragma once

#include <iostream>
#include <fstream>
using namespace std;

/**Vector3D is vector 3D representation*/
class Vector3D
{
protected:
	double _x;
	double _y;
	double _z;
public:
	Vector3D();
	Vector3D(double x,double y,double z);
    Vector3D(const Vector3D& other);
	Vector3D operator + (const Vector3D & other) const;
	Vector3D operator * (double alpha) const;
	/**sets vector to center of axis*/
    void Clear()
    {
        _x = 0;
        _y = 0;
        _z = 0;
    }
	/**this = this+other 
	*@param other: the Vector3D to perform the operation
	*@returns this*/
    Vector3D& operator +=(const Vector3D& other);
    /**this = this-other 
	*@param other: the Vector3D to perform the operation
	*@returns this*/
	Vector3D& operator -=(const Vector3D& other);
    /**this = *this = this * alpha
	*@param alpha: the alpha to perform the operation
	*@returns this*/   
	Vector3D& operator *=(double alpha);
    /**this = *this = this / alpha
	*@param alpha: the alpha to perform the operation
	*@returns this*/  
    Vector3D& operator /=(double alpha);
  
    double getX() const {return _x;}
    double getY() const {return _y;}
    double getZ() const {return _z;}
    
    void setX(double x) {_x = x;}
    void setY(double y) {_y = y;}
    void setZ(double z) {_z = z;}
};

