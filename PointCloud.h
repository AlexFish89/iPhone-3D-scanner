/** @file PointCloud.h
 * 
 *  @brief Public API for libpointcloud 
 *  
 *  Copyright 2012 13th Lab AB. All rights reserved.
 *
 *  The terms and condition for libpointcloud can be found in the LICENSE folder of the libpointcloud download, 
 *  or at http://developer.pointcloud.io/sdk/termsofuse
 *
 */

#ifndef POINTCLOUD_H
#define POINTCLOUD_H

#ifdef __cplusplus
extern "C" { 
#endif
	
    /*******
     * STATES
     ********/
    
	/** @brief System state codes
     *
	 */
    typedef enum pointcloud_state {
        POINTCLOUD_NOT_CREATED, //System not created yet, i.e. pointcloud_create has not been called yet
        POINTCLOUD_WAITING_FOR_CAMERA_FRAMES, //No valid camera frames have been received in pointcloud_on_camera_frame
        POINTCLOUD_IDLE, //System is ready and waiting for instructions
        POINTCLOUD_INITIALIZING, //SLAM intitialization process is running
        POINTCLOUD_TRACKING_SLAM_MAP, //System is tracking a slam map
        POINTCLOUD_RELOCALIZING, //Tracking is lost, trying to relocalize
        POINTCLOUD_LOOKING_FOR_IMAGES, //Looking for images
        POINTCLOUD_TRACKING_IMAGES, //Tracking images
    } pointcloud_state;
	
    /** @brief Camera video formats
     *
     */
    typedef enum pointcloud_video_format {
        POINTCLOUD_RGB_565, //RGB 565
        POINTCLOUD_NV21, //NV21
        POINTCLOUD_BGRA_8888, //32 bit BGRA 
        POINTCLOUD_GRAY_8, //Raw
    } pointcloud_video_format;
    
    /*******
     * STRUCTS
     ********/
	
    /** @brief Camera video frame and viewport info
     *
     */
    typedef struct pointcloud_context {
        pointcloud_video_format video_format;
        int video_width;
        int video_height;
        int viewport_width;
        int viewport_height;
        int video_crop_x;
        int video_crop_y;
    } pointcloud_context;
        
    /** @brief A 4x4 matrix of floats
     *
     */
    typedef struct pointcloud_matrix_4x4 {
        float data[16];
    } pointcloud_matrix_4x4;
    
    /** @brief 2D point
     *
     */
    typedef struct pointcloud_vector_2 {
        float x;
        float y;
    } pointcloud_vector_2;
	
    /** @brief 3D point
     *
     */
    typedef struct pointcloud_vector_3 {
        float x;
        float y;
        float z;
    } pointcloud_vector_3;
	
    /** @brief A point cloud, i.e. an array of 3D points
     *
     */
    typedef struct pointcloud_point_cloud {
        pointcloud_vector_3* points;
        unsigned int size;
    } pointcloud_point_cloud;
    
    /** @brief A target image
     *
     */
    typedef struct pointcloud_image_target {
        char* image_id;
        pointcloud_vector_2 dimensions;
    } pointcloud_image_target;
	
    /** @brief A list of target images
     *
     */
    typedef struct pointcloud_image_targets {
        pointcloud_image_target* targets;
        unsigned int size;
    } pointcloud_image_targets;
	
    /*******
     * CONTRUCTOR/DESTRUCTOR
     ********/
    
    /** @brief Initialize the pointcloud system. This needs to be done before calling any other methods.
     *
     * @param viewport_width	The width of the viewport the camera frame is projected on
     * @param viewport_height	The height of the viewport the camera frame is projected on
     * @param video_width		The width of a camera frame
     * @param video_height      The height of a camera frame
     * @param video_format      The format of the camera frame data
     * @param device			The device type
     * @param app_key           The developer key for the application. 
     *                          This is generated on http://developer.pointcloud.io and is specific to each application using PointCloud SDK
     */
    void pointcloud_create(int viewport_width, int viewport_height, int video_width, int video_height, 
                           pointcloud_video_format video_format, const char* device, const char* app_key);
	
    /** @brief Destroy the pointcloud system.
     *
     */
    void pointcloud_destroy();
    
    /*******
     * DATA HANDLERS
     ********/
	
    /** @brief Analyze a camera frame. Call this on on each frame.
     *
     * @param data	The camera frame pixel data
     */ 
    void pointcloud_on_camera_frame(char* data);
	
    /** @brief Notify the system of accelerometer data updates
     *
     * @param x	The acceleration in the x direction
     * @param y	The acceleration in the y direction
     * @param z	The acceleration in the z direction
     */
    void pointcloud_on_accelerometer_update(float x, float y, float z);
	
    /** @brief Notify the system of user gyro and relative acceleration updates
     *
     * @param x	The acceleration in the x direction
     * @param y	The acceleration in the y direction
     * @param z	The acceleration in the z direction
     * @param rot_x	The rotation rate in the x direction
     * @param rot_y	The rotation rate in the y direction
     * @param rot_z	The rotation rate in the z direction
     */
    void pointcloud_on_device_motion_update(float x, float y, float z, float rot_x, float rot_y, float rot_z);
	
    /*******
     * ACTIONS
     ********/
    
    /** @brief Start the initialization process. The user should move the device slowly left/right, up/down, in/out until a slam map has been created
     *
     */
    void pointcloud_start_slam();
    
    /** @brief Stop tracking or initialization and reset to an idle state. This will destroy the current point cloud.
     *
     */
    void pointcloud_reset();
    
    /** @brief Enabling map expansion will create an expanding SLAM map.
     * This way you can initialize a SLAM map from an image target. This is enabled by default when pointcloud_start_slam() is called.
     *
     */
    void pointcloud_enable_map_expansion();

	/** @brief Stops any ongoing map expansion. 
	 * Freezes the current map.
     *
     */
    void pointcloud_disable_map_expansion();
	
    /** @brief Add a reference image to the system. Note that you need to activate the image (pointcloud_activate_image_target) if you want the system to detect it.
     *
     */
    void pointcloud_add_image_target(const char* image_id, const char* file_path, float physical_width, float physical_height);
	
    /** @brief Remove a reference image from the system.
     *
     */
    void pointcloud_remove_image_target(const char* image_id);
	
    /** @brief Activate a reference image, i.e. tell the system to try to detect and track it
     *
     */
    void pointcloud_activate_image_target(const char* image_id);
	
    /** @brief Deactivate a reference image, i.e. tell the system to stop detecting or tracking it
     *
     */
    void pointcloud_deactivate_image_target(const char* image_id);
    
    /** @brief Save the current 3D map to disk
     *
     */ 
    void pointcloud_save_current_map(const char* file_path);
    
    /** @brief Load a 3D map from disk
     *
     */
    void pointcloud_load_map(const char* file_path);
    
    /*******
     * GETTERS
     ********/
    
    /** @brief Get the viewport and video context
     *
     * @return The viewport and video context
     */
    pointcloud_context pointcloud_get_context();
	
    /** @brief Get the current system state
     *
     * @return The current system state
     */
    pointcloud_state pointcloud_get_state();
	
    /** @brief Get the current revision of the point cloud
     *
     * @return The current point cloud revision number
     */
    int pointcloud_get_point_cloud_revision();
    
    /** @brief Get number of points in the point cloud
     *
     * @return The number of points in the point cloud
     */
    int pointcloud_point_cloud_size();
    
    /** @brief Get a copy of the point cloud used when tracking. Only valid during tracking or relocalization states.
     * Make sure to do pointcloud_destroy_point_cloud on the point cloud after you are done using it.
     *
     * @return A copy of the point cloud 
     */
    pointcloud_point_cloud* pointcloud_get_points();
	
    /** @brief Destroy a point cloud copy. This will not affect the internal system point cloud. 
     * Always call this after you are finished using a point cloud.
     *
     * @param points The point cloud copy to destroy
     */
    void pointcloud_destroy_point_cloud(pointcloud_point_cloud* points);
	
    /** @brief Get a copy of the current camera matrix. Only valid during the tracking states.
     * The camera matrix describes the transform from 3D map space to 3D camera space. The
	 * camera matrix is the inverse of the camera pose matrix.
	 *
     * @return The camera matrix (4x4) represented as an array of 16 floats in column major order
     */
    pointcloud_matrix_4x4 pointcloud_get_camera_matrix();
	
	/** @brief Get a copy of the current camera pose matrix. Only valid during the tracking states. 
	 * The camera pose matrix represents the current position and rotation of the device camera
	 * in the map space. The camera pose matrix is the inverse of the camera matrix.
	 * 
     * @return The camera pose matrix (4x4) represented as an array of 16 floats in column major order
     */
    pointcloud_matrix_4x4 pointcloud_get_camera_pose();
    
    /** @brief Get a vector representing the gravity direction, only valid when there is a map
     *
     * @return the gravity vector
     */
    pointcloud_vector_3 pointcloud_get_gravity_vector();
	
    /** @brief Get the currently tracked images, returns an empty pointcloud_image_targets if no image is tracked
     *
     * @return the currently tracked images, or an empty pointcloud_image_targets if no image is tracked
     */
    pointcloud_image_targets pointcloud_get_tracked_images();
    
    /** @brief Get a OpenGL compatible view frustum matrix compatible with the video feed when clipped according to the result of pointcloud_get_video_clipping()
     *
     * @param near clipping plane
     * @param far clipping plane
     * @return 4x4 column major matrix of floats
     */
    pointcloud_matrix_4x4 pointcloud_get_frustum(float near, float far);
	
	/*******
     * COORDINATE TRANSFORMS
     ********/
	
    /** @brief Unproject a 2d video coordinate to a camera relative 3d coordinate
     *
     * @param x The x coordinate
     * @param y The y coordinate
     * @return The unprojected point
     */
    pointcloud_vector_3 pointcloud_video_to_camera(float x, float y);
	
    /** @brief Project a camera relative 3d coordinate to a 2d video coordinate
     *
     * @param x The x coordinate
     * @param y The y coordinate
     * @param z The z coordinate
     * @return The projected point
     */
    pointcloud_vector_2 pointcloud_camera_to_video(float x, float y, float z);
	
	/** @brief Transform a 3d coordinate relative to the current camera into a map 3d coordinate
     *
     * @param x The x coordinate
     * @param y The y coordinate
     * @param z The z coordinate
     * @return The 3d map coordinate
     */
	pointcloud_vector_3 pointcloud_camera_to_map(float x, float y, float z);
	
	/** @brief Transform a map 3d coordinate into a coordinate relative to the current camera
     *
     * @param x The x coordinate
     * @param y The y coordinate
     * @param z The z coordinate
     * @return The camera relative 3d coordinate
     */
	pointcloud_vector_3 pointcloud_map_to_camera(float x, float y, float z);
	
    /** @brief Transform a 2d video coordinate to a 2d viewport coordinate
     *
     * @param x The x video coordinate
     * @param y The y video coordinate
     * @return The 2d viewport coordinate
     */
    pointcloud_vector_2 pointcloud_video_to_viewport(float x, float y);
	
    /** @brief Transform a 2d viewport coordinate to a 2d video coordinate
     *
     * @param x The x viewport coordinate
     * @param y The y viewport coordinate
     * @return The 2d video coordinate
     */
    pointcloud_vector_2 pointcloud_viewport_to_video(float x, float y);
	
#ifdef __cplusplus
}
#endif

#endif // POINTCLOUD_H