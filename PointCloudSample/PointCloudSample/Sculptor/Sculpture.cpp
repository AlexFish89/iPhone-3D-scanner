//
//  Sculpture.cpp
//  PointCloudSample
//
//  Created by admin on 8/28/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include "Sculpture.h"
#include <limits.h>
#include <math.h>

Sculpture::Sculpture() {
//    sculpture = new byte[SCULPTURE_SIZE * SCULPTURE_SIZE * SCULPTURE_SIZE];
//    colors = new byte[SCULPTURE_SIZE * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS];
    this->setAll();
}

Sculpture::~Sculpture() {
//    delete[] sculpture;
//    delete[] colors;
}

void Sculpture::setBit(int x, int y, int z) {
//    this->sculpture[x/8 + y * SCULPTURE_SIZE / 8 + z * SCULPTURE_SIZE * SCULPTURE_SIZE / 8] |= static_cast<unsigned char>(pow((double)2,x%8));
    this->sculpture[x + y * SCULPTURE_SIZE + z * SCULPTURE_SIZE * SCULPTURE_SIZE] = STEP;
}

void Sculpture::unsetBit(int x, int y, int z) {
//    this->sculpture[x/8 + y * SCULPTURE_SIZE / 8 + z * SCULPTURE_SIZE * SCULPTURE_SIZE / 8] &= ~(static_cast<unsigned char>(pow((double)2,x%8)));
    if (this->sculpture[x + y * SCULPTURE_SIZE + z * SCULPTURE_SIZE * SCULPTURE_SIZE]) {
        this->sculpture[x + y * SCULPTURE_SIZE + z * SCULPTURE_SIZE * SCULPTURE_SIZE]--;
    }
}

bool Sculpture::getBit(int x, int y, int z) const {
    return this->sculpture[x + y * SCULPTURE_SIZE + z * SCULPTURE_SIZE * SCULPTURE_SIZE];
}

void Sculpture::setAll() {
    for (int i = contour ; i < SCULPTURE_SIZE - contour ; i++) {
        for (int j = contour ; j < SCULPTURE_SIZE - contour ; j++) {
            for (int k =  contour ; k < SCULPTURE_SIZE - contour ; k++) {
                this->setBit(k, j, i);
            }
        }
    }
}

void Sculpture::unsetAll() {
    for (int i = 0 ; i < SCULPTURE_SIZE ; i++) {
        for (int j = 0 ; j < SCULPTURE_SIZE ; j++) {
            for (int k = 0 ; k < SCULPTURE_SIZE ; k++) {
                this->unsetBit(k, j, i);
            }
        }
    }
}

void Sculpture::setColor(int x, int y, int z, byte r, byte g, byte b, byte a) {
    this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + RED_CHANNEL] = r;
    this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + GREEN_CHANNEL] = g;
    this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + BLUE_CHANNEL] = b;
    this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + ALPHA_CHANNEL] = a;
}

bool Sculpture::getColor(int x, int y, int z, byte& r, byte& g, byte& b, byte& a) const {
    if (!getBit(x, y, z)) {
        return false;
    }
    r = this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + RED_CHANNEL];
    g = this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + GREEN_CHANNEL];
    b = this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + BLUE_CHANNEL];
    a = this->colors[x * CHANNELS + y * SCULPTURE_SIZE * CHANNELS + z * SCULPTURE_SIZE * SCULPTURE_SIZE * CHANNELS + ALPHA_CHANNEL];
    return true;
}

Mesh const& Sculpture::getMesh() const{
    return mesh;
}

void Sculpture::getProjection(double& x, double& y, double& z, const Mat& projection) {
    double pointMat[4];
    float cornerX, cornerY, cornerZ;
    boundingBox.getCorner(cornerX, cornerY, cornerZ);
    pointMat[0] = (x / SCULPTURE_SIZE) * boundingBox.getSize() + cornerX;
    pointMat[1] = (y / SCULPTURE_SIZE) * boundingBox.getSize() + cornerY;
    pointMat[2] = (z / SCULPTURE_SIZE) * boundingBox.getSize() + cornerZ;
    pointMat[3] = 1.0;

    double projX =  pointMat[0] * projection.at<double>(0,0) +
                    pointMat[1] * projection.at<double>(0,1) +
                    pointMat[2] * projection.at<double>(0,2) +
                    1           * projection.at<double>(0,3);
    
    double projY =  pointMat[0] * projection.at<double>(1,0) +
                    pointMat[1] * projection.at<double>(1,1) +
                    pointMat[2] * projection.at<double>(1,2) +
                    1           * projection.at<double>(1,3);
    
    double projZ =  pointMat[0] * projection.at<double>(2,0) +
                    pointMat[1] * projection.at<double>(2,1) +
                    pointMat[2] * projection.at<double>(2,2) +
                    1           * projection.at<double>(2,3);
    
    x = round(projX / projZ);
    y = round(projY / projZ);
}

inline bool pointOffSilhouette(const Mat& silhouette, int x, int y) {
    return silhouette.at<Vec4b>(y,x)[1] == 0;
}

void Sculpture::sculpt(const ImageData& imgData, const Cube& bBox) {
    int width = imgData.image.cols;
    int height = imgData.image.rows;
    cameras.push_back(ImageData(imgData));
    boundingBox = bBox;
    for (int i = 0 ; i < SCULPTURE_SIZE ; i++) {
        for (int j = 0 ; j < SCULPTURE_SIZE; j++) {
            for (int k = 0 ; k < SCULPTURE_SIZE; k++) {
                if (!this->getBit(i, j, k)) continue;
                double x = i, y = j, z = k;
                this->getProjection(x, y, z, imgData.P);
                if (x < width && x >= 0 && y < height && y >= 0) {
                    if (pointOffSilhouette(imgData.silhouette,x,y)) {
                        this->unsetBit(i, j, k);
                    }
                } else {
                    this->unsetBit(i, j, k);
                }
            }
        }
    }
}


void Sculpture::initGrid(GRIDCELL& grid, double x, double y, double z) {
    double left = x,right = x + 1,top = y + 1,bot = y,near = z,far = z + 1;

    (grid.val)[0] = this->getBit(  left,    bot,    near );
    (grid.val)[1] = this->getBit(  left,    bot,    far  );
    (grid.val)[2] = this->getBit(  right,   bot,    far  );
    (grid.val)[3] = this->getBit(  right,   bot,    near );
    (grid.val)[4] = this->getBit(  left,    top,    near );
    (grid.val)[5] = this->getBit(  left,    top,    far  );
    (grid.val)[6] = this->getBit(  right,   top,    far  );
    (grid.val)[7] = this->getBit(  right,   top,    near );
    
    (grid.p)[0] = Vector3DEx(  left,    bot,    near    );
    (grid.p)[1] = Vector3DEx(  left,    bot,    far     );
    (grid.p)[2] = Vector3DEx(  right,   bot,    far     );
    (grid.p)[3] = Vector3DEx(  right,   bot,    near    );
    (grid.p)[4] = Vector3DEx(  left,    top,    near    );
    (grid.p)[5] = Vector3DEx(  left,    top,    far     );
    (grid.p)[6] = Vector3DEx(  right,   top,    far     );
    (grid.p)[7] = Vector3DEx(  right,   top,    near    );
}

void Sculpture::interpolateColor(int x, int y, int z, double xPart, double yPart, double zPart, byte& r, byte& g, byte& b, byte& a) {
    getColor(x, y, z, r, g, b, a);
    x += 1 - doubleEqual(xPart, 0.0);
    y += 1 - doubleEqual(yPart, 0.0);
    z += 1 - doubleEqual(zPart, 0.0);
    byte r2,g2,b2,a2;
    getColor(x, y, z, r2, g2, b2, a2);
    r = (r + r2) / 2;
    g = (g + g2) / 2;
    b = (b + b2) / 2;
    a = (a + a2) / 2;
}

void Sculpture::addTrianglesToZbuffer(vector<Triangle>& triangles, Zbuffer& zBuff, ImageData& imgData) {
    for(int i = 0; i < triangles.size(); ++i) {
        for (int j = 0 ; j < 3 ; ++j) {
            double x = (triangles[i].p)[j][0], y = (triangles[i].p)[j][1], z = (triangles[i].p)[j][2];
            getProjection(x, y, z, imgData.P);
            if (x >= imgData.image.cols || x < 0 || y >= imgData.image.rows || y < 0 || pointOffSilhouette(imgData.silhouette, x, y)) {
                continue;
            }
            Vec3f voxel((triangles[i].p)[j][0],(triangles[i].p)[j][1],(triangles[i].p)[j][2]);
            zBuff.addVertex(x, y, voxel, imgData.rt);
        }
    }
}

#define zThresh 0.1

void Sculpture::addColorToTrianglesWithZbufferAndImage(vector<Triangle>& triangles, Zbuffer& zBuff, ImageData& imgData) {
    for(int i = 0; i < triangles.size(); ++i) {
        for (int j = 0 ; j < 3 ; ++j) {
            double x = (triangles[i].p)[j][0], y = (triangles[i].p)[j][1], z = (triangles[i].p)[j][2];
            getProjection(x, y, z, imgData.P);
            if (x >= imgData.image.cols || x < 0 || y >= imgData.image.rows || y < 0 || pointOffSilhouette(imgData.silhouette, x, y)) {
                continue;
            }
            float ownZ =    (triangles[i].p)[j][0] * imgData.rt.at<float>(2,0) +
                            (triangles[i].p)[j][1] * imgData.rt.at<float>(2,1) +
                            (triangles[i].p)[j][2] * imgData.rt.at<float>(2,2) +
                            1                      * imgData.rt.at<float>(2,3);
            float bufferZ = zBuff.getVertex(x, y);
            if (abs(bufferZ - ownZ) < zThresh * abs(bufferZ)) {
                Vec4i color = imgData.image.at<Vec4b>(y,x);
                (triangles[i].color)[j] += color;
                ++(triangles[i].cameras)[j];
            }
        }
    }
}

void Sculpture::addColorToTrianglesFromOneImage(vector<Triangle>& triangles, ImageData& imgData) {
    Zbuffer zBuff(imgData.image.cols, imgData.image.rows);
    addTrianglesToZbuffer(triangles,zBuff,imgData);
    addColorToTrianglesWithZbufferAndImage(triangles,zBuff,imgData);
}

void forceColor(vector<Triangle>& triangles, int triangleNumber, int vertexNumber) {
    if (triangleNumber >= triangles.size() || vertexNumber > 2) {
        return;
    }
    for (int i = triangleNumber ; i < triangles.size() ; ++i) {
        for (int j = 0 ; j < 3 ; ++j) {
            if ((triangles[i].cameras)[j]) {
                (triangles[triangleNumber].color)[vertexNumber] = (triangles[i].color)[j];
                return;
            }
        }
    }
    for (int i = triangleNumber - 1 ; i >= 0 ; --i) {
        for (int j = 0 ; j < 3 ; ++j) {
            if ((triangles[i].cameras)[j]) {
                (triangles[triangleNumber].color)[vertexNumber] = (triangles[i].color)[j];
                return;
            }
        }
    }
}

void ForceRemainingColors(vector<Triangle>& triangles) {
    for (int i = 0 ; i < triangles.size() ; ++i) {
        for (int j = 0 ; j < 3 ; ++j) {
            if (!(triangles[i].cameras)[j]) {
                forceColor(triangles,i,j);
            }
        }
    }
}

void Sculpture::updateColors(vector<Triangle>& triangles) {
    for (int i = 0 ; i < cameras.size() ; ++i) {
        addColorToTrianglesFromOneImage(triangles, cameras[i]);
    }
    for (int i = 0 ; i < triangles.size() ; ++i) {
        for (int j = 0 ; j < 3 ; ++j) {
            if ((triangles[i].cameras)[j]) {
                for (int k = 0 ; k < 4 ; ++k) {
                    (triangles[i].color)[j][k] /= (triangles[i].cameras)[j];
                }
            }
        }
    }
    ForceRemainingColors(triangles);
}

//void Sculpture::trianglesToMesh(vector<Triangle>& triangles) {
//    mesh.setNumberOfTriangles(triangles.size());
//    for(int i = 0; i < triangles.size(); ++i) {
//        for (int j = 0 ; j < 3 ; ++j) {
//            mesh.addVertex((triangles[i].p)[j][0] - (SCULPTURE_SIZE / 2), (triangles[i].p)[j][1] - (SCULPTURE_SIZE / 2), -(triangles[i].p)[j][2] + (SCULPTURE_SIZE / 2));
//            mesh.addNormal((triangles[i].normal)[0], (triangles[i].normal)[1], (triangles[i].normal)[2]);
//            mesh.addColor((triangles[i].color)[j][0], (triangles[i].color)[j][1], (triangles[i].color)[j][2], (triangles[i].color)[j][3]);
//        }
//    }    
//}

void Sculpture::trianglesToMesh(vector<Triangle>& triangles) {
    mesh.setNumberOfTriangles(triangles.size());
    while (triangles.size()) {
        Triangle curTriangle = triangles.back();
        triangles.pop_back();
        for (int j = 0 ; j < 3 ; ++j) {
            mesh.addVertex((curTriangle.p)[j][0] - (SCULPTURE_SIZE / 2), (curTriangle.p)[j][1] - (SCULPTURE_SIZE / 2), -(curTriangle.p)[j][2] + (SCULPTURE_SIZE / 2));
            mesh.addNormal((curTriangle.normal)[0], (curTriangle.normal)[1], (curTriangle.normal)[2]);
            mesh.addColor((curTriangle.color)[j][0], (curTriangle.color)[j][1], (curTriangle.color)[j][2], (curTriangle.color)[j][3]);
        }
    }
}

int Sculpture::createMesh() {
    vector<Triangle> triangles;
    for (int i = 0 ; i < SCULPTURE_SIZE - 1 ; i++) {
        for (int j = 0 ; j < SCULPTURE_SIZE - 1 ; j++) {
            for (int k = 0 ; k < SCULPTURE_SIZE - 1 ; k++) {
                GRIDCELL grid;
                this->initGrid(grid, i, j, k);
                Polygonise(grid, 0.5, triangles);
            }
        }
    }
    updateColors(triangles);
    mesh.clear();
    trianglesToMesh(triangles);
    return mesh.getNumberOfTriangles();
}


string Sculpture::rawData() const {
    ostringstream result;
    for (int i = 0 ; i < SCULPTURE_SIZE ; i++) {
        for (int j = 0 ; j < SCULPTURE_SIZE ; j++) {
            for (int k = 0 ; k < SCULPTURE_SIZE ; k++) {
                if (this->getBit(k, j, i)) {
                    result << '1';
                } else {
                    result << '0';
                }
                result << ',';
            }
        }
    }
    return result.str().substr(0,result.str().size() - 1);
}

string Sculpture::objData() const {
    ostringstream obj;
    const vector<float>& vertices = mesh.getVertices();
    for (int i = 0 ; i < vertices.size() ; i += 3) {
        obj << "v " << vertices[i + 0] << " " << vertices[i + 1] << " " << vertices[i + 2] << endl;
    }
    for (int i = 0 ; i < mesh.getNumberOfTriangles() ; ++i) {
        obj << "f " << 3 * i + 1  << " " << 3 * i + 2 << " " << 3 * i + 3 << endl;
    }
    return obj.str();
}

string Sculpture::plyData() const {
    ostringstream ply;
    const vector<float>& vertices = mesh.getVertices();
    const vector<byte>& colors = mesh.getColors();
    int verticesNumber = mesh.getNumberOfVertices();
    ply << "ply" << endl << "format ascii 1.0" << endl << "comment author: Alex Fish" << endl;
    ply << "element vertex " << verticesNumber << endl;
    ply << "property float x" << endl << "property float y" << endl << "property float z" << endl;
    ply << "property uchar red" << endl << "property uchar green" << endl << "property uchar blue" << endl << "property uchar alpha" << endl;
    ply << "element face " << mesh.getNumberOfTriangles() << endl << "property list int int vertex_index" << endl;
    ply << "end_header" <<endl;
    for (int i = 0 ; i < verticesNumber ; ++i) {
        ply << vertices[i * 3 + 0] << " " << vertices[i * 3 + 1] << " " << vertices[i * 3 + 2] << " "
            << (int)colors[i * 4 + 0] << " " << (int)colors[i * 4 + 1] << " " << (int)colors[i * 4 + 2] << " " << (int)colors[i * 4 + 3] << endl;
    }
    for (int i = 0 ; i < mesh.getNumberOfTriangles() ; ++i) {
        ply << "3 " << 3 * i + 0  << " " << 3 * i + 1 << " " << 3 * i + 2 << endl;
    }
    return ply.str();
}