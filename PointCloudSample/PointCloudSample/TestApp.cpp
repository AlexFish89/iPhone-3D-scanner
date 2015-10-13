/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */ 

#include "TestApp.h"
#include "PointCloud.h"
#include <string>

TestApp::TestApp(int viewport_width, int viewport_height, 
				 int video_width, int video_height, 
				 pointcloud_video_format video_format,
				 const char* resource_path, 
				 const char* documents_path,
				 const char* device,
				 double ui_scale_factor) :
PointCloudApplication(viewport_width, viewport_height,
					  video_width, video_height,
					  video_format,
					  resource_path,
					  documents_path,
					  device,
					  ui_scale_factor)
{
	setup_Cube();
	
	// Add images to look for (detection will not start until images are activated, though)
	std::string image_target_1_path = resource_path + std::string("image_target_1.model");
    std::string image_target_2_path = resource_path + std::string("image_target_2.model");
    
    pointcloud_add_image_target("image_1", image_target_1_path.c_str(), 0.3, -1);
    pointcloud_add_image_target("image_2", image_target_2_path.c_str(), 0.3, -1);
    	
	// Create the texture used for the UI
	ui_texture = read_png_texture("ui.png", true);

    // Init the capture flag to false until capture is pressed.
    current_picture_flag = false;
}


// Most convoluted way to make a Cube
void TestApp::setup_Cube() {   
    this->selected_button = DEMO;
}

void TestApp::draw_ui() {
	// Draws a basic UI to control the demo app
	pointcloud_state state = pointcloud_get_state();
	double now = current_time();
	bool is_slam = !(state == POINTCLOUD_LOOKING_FOR_IMAGES || state == POINTCLOUD_TRACKING_IMAGES);
	
	int w = context.viewport_width;
	int h = context.viewport_height;
	double scale_factor = w == 320 ? 0.5 : 1.0;
	double text_w = 138*scale_factor;
	double text_h = 112*scale_factor;
	
	double footer_h = 112*scale_factor;
	static double third = 1.0/3.0;
	
	
	
//	// Header background
//	draw_image(ui_texture, 0, 20, w, 60*scale_factor, 1/512.0, 332/512.0, 25/512.0, (332+60)/512.0);
//	
//	// Header text
//	draw_image(ui_texture, (w-283*scale_factor)/2, 20+((60-36)/2)*scale_factor, 283*scale_factor, 36*scale_factor, 1/512.0, 289/512.0, 283/512.0, (289+36)/512.0);
	

	// Footer
	if (this->selected_button == MESH) {
		// Image Recognition button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
	}
	else if (this->selected_button == DEMO){
		// SLAM button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0 );
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
	} 
    else if (this->selected_button == CAPTURE){
		// SLAM with Image button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0);
	} 
	
	// Footer text
	draw_image(ui_texture, w/6-text_w/2,	h-text_h, text_w, text_h,   96/512.0, 400/512.0,  (96+138)/512.0, 512/512.0);
	draw_image(ui_texture, w/2-text_w/2,	h-text_h, text_w, text_h,  235/512.0, 400/512.0, (235+138)/512.0, 512/512.0);
	draw_image(ui_texture, 5*w/6-text_w/2,	h-text_h, text_w, text_h,  374/512.0, 400/512.0, (374+138)/512.0, 512/512.0);
	
	// Initialization
	if (is_slam) {
		if (state == POINTCLOUD_TRACKING_SLAM_MAP && last_state == POINTCLOUD_INITIALIZING) {
			init_fadeout_time = now;
		}
		
		double init_fadeout_factor = 1-(now - init_fadeout_time)/2.0; // Fade out in 2 seconds
		
		if (this->selected_button == DEMO && ((state != POINTCLOUD_TRACKING_SLAM_MAP && state != POINTCLOUD_RELOCALIZING) || init_fadeout_factor > 0)) {
			int box_x = (w-429*scale_factor)/2;
			int box_y = (h-289*scale_factor)/2;
			
			// Arrow
			int arrowOffset = 0;
			double opacity = 1.0;
			if (state == POINTCLOUD_INITIALIZING) {
				arrowOffset = 59*scale_factor; 
			}
			else if (state == POINTCLOUD_TRACKING_SLAM_MAP) {
				opacity = init_fadeout_factor;
				arrowOffset = 146*scale_factor;
			}
			
			// Draw init box
			draw_image(ui_texture,box_x, box_y, 429*scale_factor, 289*scale_factor,  1/512.0, 1/512.0, 429/512.0, 289/512.0, opacity);	
			
			// Draw arrow
			draw_image(ui_texture, box_x+26*scale_factor, box_y+86*scale_factor+arrowOffset, 30*scale_factor, 28*scale_factor,  45/512.0, 349/512.0, (45+30)/512.0, (349+28)/512.0, opacity);	
			
		}
	}
	else if (state == POINTCLOUD_LOOKING_FOR_IMAGES) {
		// Show Looking for images.. 
		// Draw top of init box
		int box_x = (w-429*scale_factor)/2;
		int box_y = (h-49*scale_factor)/2;
		draw_image(ui_texture,box_x, box_y, 429*scale_factor, 49*scale_factor,  1/512.0, 1/512.0, 20/512.0, 49/512.0);	
		
		// Draw text 268x34
		draw_image(ui_texture, (w-268*scale_factor)/2, (h-34*scale_factor)/2, 268*scale_factor, 34*scale_factor, 113/512.0, 349/512.0, (113+268)/512.0, (349+34)/512.0);
	}
	
}


void TestApp::render_content(double time_since_last_frame) {
	
    pointcloud_state state = pointcloud_get_state();
	
	// Draw the content if we have SLAM or image tracking
	if (state == POINTCLOUD_TRACKING_SLAM_MAP || state == POINTCLOUD_TRACKING_IMAGES) {

		switch_to_camera();
        
		glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
		
		glDisable(GL_TEXTURE_2D);
		glEnable(GL_COLOR_MATERIAL);
		glShadeModel(GL_FLAT);
		
		glEnableClientState(GL_VERTEX_ARRAY);        
        float *lines = cube.getLines();
        for (int i = 0 ; i < numOfLines ; ++i) {
            glVertexPointer(numOfCoords, GL_FLOAT, 0, lines + i * 2 * numOfCoords);
            glDrawArrays(GL_LINES, 0, 2);
        }
		glDisableClientState(GL_VERTEX_ARRAY);
		
        //Draw Axes
        {
            const GLfloat lineX[] = {
                -100.0f, 0.0f, 0.0f, //point A
                100.0f, 0.0f, 0.0f //point B
            };
            const GLfloat lineY[] = {
                0.0f , -100.0f, 0.0f, //point A
                0.0f , 100.0f, 0.0f //point B
            };
            const GLfloat lineZ[] = {
                0.0f, 0.0f, -100.0f, //point A
                0.0f, 0.0f, 100.0f //point B
            };
            
            glEnableClientState(GL_VERTEX_ARRAY);
            
            glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
            glVertexPointer(3, GL_FLOAT, 0, lineX);
            glDrawArrays(GL_LINES, 0, 2);
            
            glColor4f(0.0f, 1.0f, 0.0f, 1.0f); // opaque green
            glVertexPointer(3, GL_FLOAT, 0, lineY);
            glDrawArrays(GL_LINES, 0, 2);
            
            glColor4f(0.0f, 0.0f, 1.0f, 1.0f); // opaque blue
            glVertexPointer(3, GL_FLOAT, 0, lineZ);
            glDrawArrays(GL_LINES, 0, 2);
            
            glDisableClientState(GL_VERTEX_ARRAY);
        }
        
		glShadeModel(GL_SMOOTH);
		glDisable(GL_COLOR_MATERIAL);
		glColor4f(1, 1, 1, 1);
	}
	
	// Draw the UI on top of the content
	switch_to_ortho();
	draw_ui();
}


bool TestApp::on_touch_started(double x, double y) {
	
	pointcloud_state state = pointcloud_get_state();
	int W = context.viewport_width;
	int H = context.viewport_height;
	
	if (y > H-112) {
		if (x < W/3) {
			// Capture button pressed
            set_current_picture_flag();
		}
		else if (x >= W/3 && x < W*2/3) {
			// Demo button pressed
            set_demo_flag();
		} 
        else {
            // MESH button pressed
            set_mesh_flag();
		}
        
		return true;
	}
	else if (state != POINTCLOUD_LOOKING_FOR_IMAGES && state != POINTCLOUD_TRACKING_IMAGES) { 
		if (pointcloud_get_state() == POINTCLOUD_IDLE) {
			printf("Start intialization\n");
			pointcloud_start_slam();
		} else {
//			printf("Resetting\n");
//			pointcloud_reset();
		}
		return true;
	}
	return false;
}

bool TestApp::on_touch_moved(double x, double y) {
	return false;
}

bool TestApp::on_touch_ended(double x, double y) {
	return false;
}

bool TestApp::on_touch_cancelled(double x, double y) {
	return false;
}



