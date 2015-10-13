#pragma once

#include "Vector3DEx.h"
#include <opencv2/opencv.hpp>
/**is triangle representation
*containes 3 points, normal of the triangle,and its edges
*@see Vector3DEx,Edge
*/

using namespace cv;

class Triangle
{
public:
	Vector3DEx p[3];
	Vector3DEx normal;
    Vec4i color[3];
    int cameras[3];        //number of cameras that see each triangle vertex
    
	Triangle(Vector3DEx first,Vector3DEx second,Vector3DEx third);
	Triangle(const Triangle& other);
    ~Triangle(void);
	void print(ostream& os) const;    
    /**
	*@param other: the other triangle to perform operation with
	*@returns if this triangle equals to other first and second and third points in given order*/
    bool operator==(const Triangle& other);
private:
	void CalculateNormal();
};