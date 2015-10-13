//
//  Mesh.h
//  PointCloudSample
//
//  Created by admin on 11/12/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#ifndef __PointCloudSample__Mesh__
#define __PointCloudSample__Mesh__

enum {
    RED_CHANNEL =0,
    GREEN_CHANNEL,
    BLUE_CHANNEL,
    ALPHA_CHANNEL,
    CHANNELS
};

typedef unsigned char byte;

using namespace std;

class Mesh {
    vector<float> vertices;
    vector<float> normals;
    vector<byte> colors;
    int numberOfTriangles;
public:
    Mesh();
    Mesh(const Mesh& mesh);
    
    const vector<float>& getVertices() const;
    const vector<float>& getNormals() const;
    const vector<byte>& getColors() const;
    int getNumberOfVertices() const;            //returns the number of vertices * 3
    int getNumberOfNormals() const;             //returns the number of normals * 3
    int getNumberOfColors() const;              //returns the number of colors * CHANNELS
    int getNumberOfTriangles() const;
    
    void setVertices(const vector<float>& vertices);
    void setNormals(const vector<float>& normals);
    void setColors(const vector<byte>& colors);
    void setNumberOfTriangles(const int numberOfTriangles);
    
    void clear();
    
    void addVertex(const float& x, const float& y, const float& z);
    void addNormal(const float& x, const float& y, const float& z);
    void addColor(byte r, byte g, byte b, byte a);
};

#endif /* defined(__PointCloudSample__Mesh__) */
