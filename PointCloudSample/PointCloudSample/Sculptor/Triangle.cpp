#include "Triangle.h"

Triangle::Triangle(Vector3DEx first,Vector3DEx second,Vector3DEx third) {
	p[0] = first;
	p[1] = second;
	p[2] = third;
	CalculateNormal();
    for (int i = 0 ; i < 3 ; ++i) {
        color[i] = Vec4i(0,0,0,0);
        cameras[i] = 0;
    }
}

Triangle::Triangle(const Triangle& other) {
	p[0] = other.p[0];
	p[1] = other.p[1];
	p[2] = other.p[2];
	CalculateNormal();
    for (int i = 0 ; i < 3 ; ++i) {
        color[i] = other.color[i];
        cameras[i] = other.cameras[i];
    }
}

Triangle::~Triangle(void) {
}

void Triangle::CalculateNormal() {
	Vector3DEx vector1 = p[1] - p[0];
	Vector3DEx vector2 = p[2] - p[0];
	normal = vector2.crossProduct(vector1);
}

bool Triangle::operator==(const Triangle& other) {
    return p[0] == other.p[0] && p[1] == other.p[1] && p[2] == other.p[2];
}
