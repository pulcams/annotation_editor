#!/usr/bin/env python
#-*- coding: utf-8 -*-

import glob, os, sys
"""
For Annotation Editor
Pass in e.g. 1.svg to generate html
svg filename is passed in using makeviz.sh, which is triggered by watcher.sh
from 201711
pmg
"""

def make_html(fname):
	"""
	generate reports.html
	"""
	html = """
	<!--
	 * Copyright (c) 2015 Mountainstorm
	 * 
	 * Permission is hereby granted, free of charge, to any person obtaining a copy
	 * of this software and associated documentation files (the "Software"), to deal
	 * in the Software without restriction, including without limitation the rights
	 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the Software is
	 * furnished to do so, subject to the following conditions:
	 * 
	 * The above copyright notice and this permission notice shall be included in all
	 * copies or substantial portions of the Software.
	 * 
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	 * SOFTWARE.
	 -->
	 <html>
		<head>
			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/css/bootstrap.min.css">
			<link rel="stylesheet" href="css/graphviz.svg.css">
		</head>
	
		<style>
	        #instructions {
	            color: #fcfcfc;
	            position: absolute;
	            z-index: 100;
	            bottom: 0px;
	            left: 0px;
	        }
	    </style>
		<body>
			<h4 id="instructions">Click node to highlight; Shift-scroll to zoom; Esc to unhighlight</h4>
			<div id="graph" style="width: 100%%; height: 100%%; overflow: scroll;position: relative;"></div>
	
			<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
			<script type="text/javascript" src="https://cdn.rawgit.com/jquery/jquery-mousewheel/master/jquery.mousewheel.min.js"></script>
			<script type="text/javascript" src="https://cdn.rawgit.com/jquery/jquery-color/master/jquery.color.js"></script>
			<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/js/bootstrap.min.js"></script>
			<script type="text/javascript" src="js/jquery.graphviz.svg.js"></script>
			<script type="text/javascript">
	 			$(document).ready(function(){
	                $("#graph").graphviz({
	                    url: "%s.svg", 
	                    ready: function() {
	                        var gv = this
                                $("g.node:contains('anno') > ellipse").css('fill','#ffff80');
                                // $("g.node:contains('Anno') > ellipse").css('fill','#ffff80');
                        	$("g.node:contains('Item') > ellipse").css('fill','#99ddff');
                        	$("g.node:contains('Instance') > ellipse").css('fill','#99ddff');
                        	$("g.node:contains('Work') > ellipse").css('fill','#99ddff'); 
				$("g.node:contains('work/id') > ellipse").css('fill','#f99c9c'); 
	                        gv.nodes().click(function () {
	                            var $set = $()
	                            $set.push(this)
	                            $set = $set.add(gv.linkedFrom(this, true))
	                            $set = $set.add(gv.linkedTo(this, true))
	                            gv.highlight($set, true)
	                            gv.bringToFront($set)
	                        })
	                        $(document).keydown(function (evt) {
	                            if (evt.keyCode == 27) {
	                                gv.highlight()
	                            }
	                        })
	                    }
	                });
	            });
			</script>
		</body>
		</html>""" % (fname)

	with open('./anno/'+fname+'.html','wb+') as htmlfile:
		htmlfile.write(html)
	
if __name__ == "__main__":
	for f in os.listdir("/opt/local/basex/webapp/static/anno"):
		if 'anno/'+f == sys.argv[1]: #f.endswith(".svg"):
                        print("BING BONG from python" + f)
			fname = os.path.splitext(f)[0]
			make_html(fname)
