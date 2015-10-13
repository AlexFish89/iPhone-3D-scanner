//
//  Mesh.cpp
//  PointCloudSample
//
//  Created by admin on 11/12/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#include "Mesh.h"

Mesh::Mesh() {
    numberOfTriangles = 0;
}

Mesh::Mesh(const Mesh& mesh) {
    setNumberOfTriangles(mesh.numberOfTriangles);
    setVertices(mesh.vertices);
    setNormals(mesh.normals);
    setColors(mesh.colors);
}

const vector<float>& Mesh::getVertices() const {
    return vertices;
}

const vector<float>& Mesh::getNormals() const {
    return normals;
}

const vector<byte>& Mesh::getColors() const {
    return colors;
}

int Mesh::getNumberOfVertices() const {
    return vertices.size() / 3;
}

int Mesh::getNumberOfNormals() const {
    return normals.size();
}

int Mesh::getNumberOfColors() const {
    return colors.size();
}

int Mesh::getNumberOfTriangles() const {
    return numberOfTriangles;
}

void Mesh::setVertices(const vector<float>& vertices) {
    this->vertices = vertices;
}

void Mesh::setNormals(const vector<float>& normals) {
    this->normals = normals;
}

void Mesh::setColors(const vector<byte>& colors) {
    this->colors = colors;
}

void Mesh::setNumberOfTriangles(const int numberOfTriangles) {
    this->numberOfTriangles = numberOfTriangles;
}

void Mesh::clear() {
    vertices.clear();
    normals.clear();
    colors.clear();
    numberOfTriangles = 0;
}

void Mesh::addVertex(const float& x, const float& y, const float& z) {
    vertices.push_back(x);
    vertices.push_back(y);
    vertices.push_back(z);
}

void Mesh::addNormal(const float& x, const float& y, const float& z) {
    normals.push_back(x);
    normals.push_back(y);
    normals.push_back(z);
}

void Mesh::addColor(byte r, byte g, byte b, byte a) {
    colors.push_back(r);
    colors.push_back(g);
    colors.push_back(b);
    colors.push_back(a);
}