#pragma once

#include "Vector3D.h"

/**Vector3DEx is extendex Vector3D: needed for performance improval 
*its lenght calculated only once on creation*/
class Vector3DEx : public Vector3D
{
public:
	Vector3DEx(void);
	Vector3DEx(double x,double y,double z);
	Vector3DEx(const Vector3D& other);
	~Vector3DEx(void);
	double angle(Vector3DEx& other);
	double length();
	Vector3DEx normalize();
	Vector3DEx crossProduct(Vector3DEx& other);
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this less the other in (x,y,z) preference order*/
	bool	 operator < (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this equal other x and y and z*/
	bool	 operator ==(const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this not equal to other in x or y or z*/
	bool	 operator !=(const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns if this greater the other in (x,y,z) preference order*/
	bool     operator > (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this-other x1-x2,y1-y2,z1-z2*/
	Vector3DEx  operator - (const Vector3DEx & other) const;
	
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this+other x1+x2,y1+y2,z1+z2*/
	Vector3DEx  operator + (const Vector3DEx & other) const;
	
	/**this = this+other 
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator +=(const Vector3DEx& other);
    /**this = this-other 
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator -=(const Vector3DEx& other);
    /**this = this * alpha
	*@param other: the Vector3DEx to perform the operation
	*@returns this*/
	Vector3DEx& operator *=(double alpha);
    /**
	*@param other: the Vector3DEx to perform the operation
	*@returns this  product other */
	double	 operator	* (const Vector3DEx & other) const;
	/**
	*@param other: the Vector3DEx to perform the operation
	*@returns this * alpha. (x*alpha,y*alpha,z*alpha)*/
	Vector3DEx operator * (double alpha) const;
    
    /**
     *@param target: target coordinate - 1=x, 2=y, 3=z.
     *@returns the <target> coordinate.
     */
    double operator [] (int target) const;
	
	double getX();
	double getY();
	double getZ();

protected:
	double vectorLength;
};

