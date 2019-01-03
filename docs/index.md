# SWFTY

Blabla write something

## HTML5 Demo



<div>
	<div id="inputBox">
		<div>
			<input type="file" id="swfFile" name="swfFile" width="100%" />
		</div>
		<div class="right">
			<input type="button" id="loadDemo" name="loadDemo" value="Load Demo" />
			<input type="button" id="swftySave" name="swftySave" value="SWFTY" disabled />
			<input type="button" id="abstractsSave" name="abstractsSave" value="Abstracts" disabled />
			<input type="button" id="swftyStress" name="swftyStress" value="Stress Test" disabled />
		</div>
	</div>

	<div>
		<image id="tilemap" />
		<div id="tilemapInfo">Tilemap: not loaded</div>
	</div>

	<div>
		<select id="names" size="6" selected-index="0" required disabled>
			<option value="Not loaded">Not loaded</option>
		</select>
	</div>

</div>

<div id="content"></div>

<script type="text/javascript">
	var config = {};
	var exporter = null;
	var swfty = null;

	var loadDemoInput = document.getElementById('loadDemo');
	var swfFileInput = document.getElementById('swfFile');
	var swftySaveInput = document.getElementById('swftySave');
	var abstractsSaveInput = document.getElementById('abstractsSave');
	var stressInput = document.getElementById('swftyStress');
	var namesInput = document.getElementById('names');
	var tilemapImage = document.getElementById('tilemap');
	var tilemapInfo = document.getElementById('tilemapInfo');

	lime.embed ("SWFTYExporter", "content", 400, 300, config);

	function loadArrayBuffer(result, name) {
		SWFTY.processSWF(result, name, function(_exporter) {
			exporter = _exporter;
			abstractsSaveInput.disabled = false;

			SWFTY.getTilemap(exporter, function(src, width, height, size) {
				tilemapImage.src = src;

				tilemapInfo.innerHTML = 'Tilemap: ' + width + 'x' + height + ', (' + (Math.round(size/1024/1024*100) / 100) + 'MB)';
			});

			for(var i = namesInput.options.length - 1 ; i >= 0 ; i--) {
				namesInput.remove(i);
			}

			var names = SWFTY.exportNames(exporter);
			for (var i = 0; i < names.length; i++) {
				var name = names[i];
				var option = document.createElement("option");
				option.text = name;
				option.value = name;
				namesInput.add(option);
			}

			namesInput.selectedIndex = 0;
			
			SWFTY.exportSWF(exporter, function(_swfty) {
				console.log('Export SWF!');
				swfty = _swfty;
				swftySaveInput.disabled = false;
				
				SWFTY.renderSWFTY(swfty, function() {
					SWFTY.renderMC(namesInput.value);
					stressInput.disabled = false;
					namesInput.disabled = false;
				});
			});
		});
	} 

	function handleFileSelect(evt) {
		var files = evt.target.files; // FileList object

		// TODO: Handle more than one files
		// Loop through the FileList and render image files as thumbnails.
		for (var i = 0, f; f = files[i]; i++) {
			var reader = new FileReader();
			reader.onload = (function(theFile) {
				return function(e) {
					loadArrayBuffer(e.target.result, theFile.name);
				};
			})(f);
			reader.readAsArrayBuffer(f);

			// Only one file
			break;
		}
	}

	function handleFileSave(evt) {
		if (swfty != null && exporter != null) {
			saveAs(new Blob([swfty], {type: "application/octet-stream"}), exporter.name + '.swfty');
		}
	}

	function handleAbstractsSave(evt) {
		if (exporter != null) {
			var abstracts = SWFTY.exportAbstracts(exporter);
			saveAs(new Blob([abstracts], {type: "text/plain;charset=utf-8"}), exporter.name + '.hx');
		}
	}

	function handleNameSelect(evt) {
		if (exporter != null) {
			SWFTY.renderMC(namesInput.value);
		}
	}

	function handleStress(evt) {
		if (exporter != null) {
			SWFTY.stress();
		}
	}

	function handleDemo(evt) {
		var oReq = new XMLHttpRequest();
		oReq.open("GET", "/assets/res/Popup.swf", true);
		oReq.responseType = "arraybuffer";

		oReq.onload = function (oEvent) {
		  var arrayBuffer = oReq.response; // Note: not oReq.responseText
		  if (arrayBuffer) {
		    loadArrayBuffer(arrayBuffer, 'Popup.swf');
		  }
		};

		oReq.send(null);
	}

	loadDemoInput.addEventListener('click', handleDemo, false);
	namesInput.addEventListener('change', handleNameSelect, false);
	swfFileInput.addEventListener('change', handleFileSelect, false);
	swftySaveInput.addEventListener('click', handleStress, false);
	abstractsSaveInput.addEventListener('click', handleAbstractsSave, false);
	stressInput.addEventListener('click', handleStress, false);
</script>