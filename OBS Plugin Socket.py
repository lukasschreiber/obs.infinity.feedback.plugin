import obspython as obs
import urllib.request
import urllib.parse
import threading
import qrcode
from io import BytesIO
import base64
import json
from pathlib import Path

url = ""
key = ""

# ------------------------------------------------------------

class HttpHandler(urllib.request.HTTPHandler):
    @staticmethod
    def http_response(request, response):
        print(response.code)
        return response


def get_current_scene(data=""):
	# print("URL: "+url)
	current_scene = obs.obs_frontend_get_current_scene()
	current_scene_name = obs.obs_source_get_name(current_scene)

	preview_scene = obs.obs_frontend_get_current_preview_scene()
	preview_scene_name = obs.obs_source_get_name(preview_scene)

	all_scenes = obs.obs_frontend_get_scene_names()
	all_scenes_string = ','.join(all_scenes)


	opener = urllib.request.build_opener(HttpHandler())
	try:
		base_url = url+"update"
		params = {'key': key, 'all': all_scenes_string, 'active': current_scene_name, 'preview': preview_scene_name}
		thread = threading.Thread(target=opener.open, args=(base_url+"?"+urllib.parse.urlencode(params),))
		thread.start()
		print('exit')

		thread.join()
	except Exception as e:
		print(e)

	obs.source_list_release(all_scenes)
	obs.obs_source_release(current_scene)
	obs.obs_source_release(preview_scene)

def show_qr_code(arg1, arg2):
	qr = qrcode.QRCode(
		version=1,
		box_size=8,
		border=1,
	)
	data = {'url':url, 'key':key}
	qr.add_data(json.dumps(data))
	qr.make(fit=True)

	img = qr.make_image(fill_color="black", back_color="white")
	img.show()


def create_html_qr_code():
	qr = qrcode.QRCode(
		version=1,
		box_size=4,
		border=1,
	)
	data = {'url':url, 'key':key}
	qr.add_data(json.dumps(data))
	qr.make(fit=True)

	img = qr.make_image(fill_color="black", back_color="white")

	buffered = BytesIO()
	img.save(buffered, format="PNG")
	img_str = base64.b64encode(buffered.getvalue())
	img_base64 = "data:image/png;base64," + img_str.decode('ascii') + "="
	img_html = "<img src='"+img_base64+"'/>"
	return img_html

def propagate_streaming_started():
	print("start stream")
	opener = urllib.request.build_opener(HttpHandler())
	try:
		base_url = url+"update"
		params = {'key': key, 'stream': "true"}
		thread = threading.Thread(target=opener.open, args=(base_url+"?"+urllib.parse.urlencode(params),))
		thread.start()
		print('exit')

		thread.join()
	except Exception as e:
		print(e)

def propagate_streaming_stopped():
	print("stopped stream")
	opener = urllib.request.build_opener(HttpHandler())
	try:
		base_url = url+"update"
		params = {'key': key, 'stream': "false"}
		thread = threading.Thread(target=opener.open, args=(base_url+"?"+urllib.parse.urlencode(params),))
		thread.start()
		print('exit')

		thread.join()
	except Exception as e:
		print(e)

def on_event(event):
    if event == obs.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED :
        get_current_scene()
    elif event == obs.OBS_FRONTEND_EVENT_STREAMING_STARTED :
        propagate_streaming_started()
    elif event == obs.OBS_FRONTEND_EVENT_STREAMING_STOPPED :
        propagate_streaming_stopped()
# ------------------------------------------------------------

def script_description():
	return "<center><h2>OBS Live Feedback</h2></center>  If you hover over the questionmark, next to the Key input you will find a QR Code. Please scan the QR Code to connect the Smartphone App.<br> This Plugin calls the API whenever the active Scene is updated.<br/><br/>Made by Lukas Schreiber"
    
def script_update(settings):
	global url
	global key
	url = obs.obs_data_get_string(settings, "url")
	key = obs.obs_data_get_string(settings, "key")

def script_properties():
	props = obs.obs_properties_create()

	first = obs.obs_properties_add_text(props, "url", "URL", obs.OBS_TEXT_DEFAULT)
	second = obs.obs_properties_add_text(props, "key", "Key", obs.OBS_TEXT_DEFAULT)
	obs.obs_property_set_long_description(first, "The Server URL. Here shall be the Server Infrastructure.")
	obs.obs_property_set_long_description(second, "<div> Please scan the QR Code with the App to establish a Connection. Otherwise just type URL and Key.<br><br>"+create_html_qr_code()+"</div>")
	return props

def script_load(settings):
	sh = obs.obs_get_signal_handler()
	# obs.signal_handler_connect(sh, "source_activate", get_current_scene)
	# obs.signal_handler_connect(sh, "source_deactivate", get_current_scene)
	obs.signal_handler_connect(sh, "source_create", get_current_scene)
	obs.signal_handler_connect(sh, "source_remove", get_current_scene)

	obs.obs_frontend_add_event_callback(on_event)

	global url
	global key
	url = obs.obs_data_get_string(settings, "url")
	key = obs.obs_data_get_string(settings, "key")
	
	get_current_scene()