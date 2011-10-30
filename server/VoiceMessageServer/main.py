#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import hashlib
import urllib
import datetime
from google.appengine.ext import webapp, db
from google.appengine.ext.webapp import util
import traceback
import sys

class VoiceMessage(db.Model):
  name = db.StringProperty()
  code = db.StringProperty()
  audiofile = db.BlobProperty(default=None)
  contentType = db.StringProperty()
  etag = db.StringProperty()
  insert_time = db.DateTimeProperty(auto_now_add=True)

def getVoiceMessage(etag, code=None):
  result = db.GqlQuery("SELECT * FROM VoiceMessage WHERE etag = :1 LIMIT 1",etag).fetch(1)

  if (len(result) > 0):
    return result[0]
  else:
    return None

class DeleteHandler(webapp.RequestHandler):
     def get(self):
         db.delete(VoiceMessage.all())
         self.redirect('/')

class MainHandler(webapp.RequestHandler):
    def get(self):
        try:
            self.response.out.write('<form action="/upload" enctype="multipart/form-data" method="POST">')
            self.response.out.write("""Upload File: <input name="audiofile" type="file" /><br /><input name="Upload" type="submit" value="Upload" /> </form>""")
            query = db.GqlQuery("SELECT * FROM VoiceMessage")
            audiofiles = query.fetch(1000);
            self.response.out.write("FileList:=========================" + str(len(audiofiles)));
            for audiofile in audiofiles:
                if (audiofile.name != None):
                    self.response.out.write("<BR><a href='/audio/" + audiofile.etag + "'>" + audiofile.etag + "</a>");
        except Exception:
            self.response.out.write("Unexpceted error happen in  MainHandler! get");

    def post(self):
        try:
            self.response.headers.add_header('Set-Cookie','session=' + self.request.get("password"));
            self.response.out.write('<script>window.location= window.location.toString();</script>')
        except:
            self.response.out.write("Unexpected error happened in  MainHandler! post");

class ServeHandler(webapp.RequestHandler):
    def get(self, resource):
        resource = str(urllib.unquote(resource))

        if resource.endswith(".caf"):
            resource = resource[:-4]

        voiceMessage = VoiceMessage.get_by_key_name(resource)
        if (voiceMessage is None):
            voiceMessage = getVoiceMessage(resource);

        if (voiceMessage and voiceMessage.audiofile):
            self.response.headers['Content-Type'] = voiceMessage.contentType
            self.response.out.write(voiceMessage.audiofile)
        else:
            self.error(500)
            self.response.out.write("VoiceMessage not found")

class UploadHandler(webapp.RequestHandler):
    def post(self):
        try:
            voiceMessage = VoiceMessage()
            voicemessage = self.request.get("audiofile")
            voiceMessage.audiofile = db.Blob(voicemessage)
            voiceMessage.name = self.request.POST["audiofile"].filename[:21] + ".caf"
            voiceMessage.contentType = self.request.POST["audiofile"].type
            voiceMessage.etag =  hashlib.sha1(voiceMessage.audiofile).hexdigest()[:21]
            voiceMessage.put()
            self.response.out.write(voiceMessage.etag);
        except Exception:
            self.error(500);
            self.response.out.write("Upload error");

def main():
    application = webapp.WSGIApplication(
        [('/', MainHandler),
         ('/upload', UploadHandler),
         ('/audio/([^/]+)?', ServeHandler),
         ('/delete', DeleteHandler),
        ], debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
