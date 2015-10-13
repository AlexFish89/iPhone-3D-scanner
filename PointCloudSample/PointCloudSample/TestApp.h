/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */ 

#ifndef UIMENU_H
#define UIMENU_H

#include "PointCloudApplication.h"
#include "TextureUtilities.h"

class TestApp : public PointCloudApplication {
	
private:
    
    enum ButtonType {
        DEMO,
        CAPTURE,
        MESH,
    };
    
    ButtonType selected_button;
	
	void setup_Cube();
	double init_fadeout_time;
	void draw_ui();
    

	
	// UI texture
	GLuint ui_texture;
	
protected:
	virtual void render_content(double time_since_last_frame);
	
public:
	
	TestApp(int viewport_width, int viewport_height, 
			int video_width, int video_height, 
			pointcloud_video_format video_format,
			const char* resource_path, 
			const char* documents_path,
			const char* device,
			double ui_scale_factor);
	
	virtual bool on_touch_started(double x, double y);
	virtual bool on_touch_moved(double x, double y);
	virtual bool on_touch_ended(double x, double y);
	virtual bool on_touch_cancelled(double x, double y);
};


#endif // UIMENU_H
