$(document).on('ready', function() {
    var onGoingProcess = false,
        lastXml;
    $(':file').change(function(){
        $('#selectFile > span').text(this.files[0].name);
    });

    function submitForm() {
        $(this).attr('disabled', 'true');
        var formData = new FormData($('form')[0]);
        $.ajax({
            url: 'ajax.php',  //Server script to process data
            type: 'POST',
            dataType: 'xml',
            xhr: function() {  // Custom XMLHttpRequest
                var myXhr = $.ajaxSettings.xhr();
                if(myXhr.upload){ // Check if upload property exists
                    myXhr.upload.addEventListener('progress', progressHandlingFunction, false); // For handling the progress of the upload
                    myXhr.upload.addEventListener('load', function (e) {
                        changeStatus('process.png', 'PROCESSING');
                    }, false);
                }
                return myXhr;
            },
            //Ajax events
            beforeSend: function() {
                changeStatus('upload.png', 'UPLOADING');
            },
            success: function(xml) {
                lastXml = xml;
                changeStatus('complete.png', 'COMPLETE');
                $('#tree').show();
                $('#treeView').html('<li></li>');
                traverse($('#treeView li'), xml.firstChild, 1);
                treePostProcess();
                $("#treeView").treeview({
                    collapsed: true,
                    animated: 'fast'
                });
            },
            complete: function() {
                onGoingProcess = false;
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.log(jqXHR);
                console.log(textStatus);
                console.log(errorThrown);
            },
            // Form data
            data: formData,
            //Options to tell jQuery not to process data or worry about content-type.
            cache: false,
            contentType: false,
            processData: false
        });
    };

    function progressHandlingFunction(e){
        if(e.lengthComputable){
            $('#progressBar').width( (e.loaded / e.total) * 100 + '%');
        }
    }

    function traverse(node, tree, level) {
        var children=$(tree).children();
        if (children.length > 1){
            if (level == 1) {
                node.append('<span id="tFile"><b>' + tree.nodeName.replace(/:spirit|spirit:/g, '') + '</b></span>');
            } else {
                node.append('<span class="tSub"><b>' + tree.nodeName.replace(/:spirit|spirit:/g, '') + '</b></span>');
            }
            var ul=$('<ul data-level="' + level + '">').appendTo(node);
            children.each(function(){
                var li=$('<li>').appendTo(ul);
                traverse(li, this, level + 1);
            })
        }else{
            node.append('<span class="tSub"><b>' + tree.nodeName.replace(/:spirit|spirit:/g, '') + '</b> ' + $(tree).text() + '</span>');
            //$('<ul><li>'+ $(tree).text()+'</li></ul>').appendTo(node);
        }
    }

    function treePostProcess() {
        var $breakdowns = $("#treeView").find('ul'),
            $registers = $breakdowns.filter('[data-level="2"]');

        $('#tFile').append(' (' + $registers.size() + ' register)');
        for (var i = 0; i < $registers.length; i++) {
            $registers.eq(i).siblings('.tSub').append(' (' + $registers.eq(i).find('ul[data-level="3"]').size() + ' field)');
        }
    }

    function changeStatus(image, message) {
        $('#status')
            .css('display', 'inline-block')
            .children('img').attr('src', 'images/' + image)
            .end()
            .children('span').text(message);
    }

    $('#selectFile').on('click', function() {
        $('#file').click();
    });

    $('#uploadFile').on('click', function() {
        if (!onGoingProcess) {
            submitForm();
            onGoingProcess = true;
        }
    });

    $('#save').on('click', function() {
        var blob = new Blob([(new XMLSerializer()).serializeToString(lastXml)], {type: "application/xml;charset=utf-8"});
        saveAs(blob, "ipxact.xml");
    });
});
var debug;