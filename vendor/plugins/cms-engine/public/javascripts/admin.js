$.fn.ajaxGetLink = function(target){
  var collection = this;
  this.each(function(){
    $(this).click(function(){
      target.load( this.href );
      return false;
    })
  });
}

$.fn.ajaxForm = function(){
  this.unbind('submit').submit(function(){
    data = $(this).serializeArray();
    $.post(this.action, data, null, 'script');
    return false;
  });
}

$.fn.visible = function(){
  return this.is(':visible');
}

$(document).ready(function(){
  
  $(".ui-tabs").tabs({
    load: function(event, ui) { doContentLoaded() },
    cache: false
  });

  $("#site-map").treeTable();

  $("body").ajaxComplete(function(){

    $("#content_browser.ajax .pagination a").ajaxGetLink($("#content_browser .results"));
    $("#Children .pagination a").ajaxGetLink($("#Children"));
    doContentLoaded();

  })
  
  $('.visibility_toggle').click(function(){
    var target = $('#'+this.target);
    if( target.visible()){
      target.hide();
      $(this).html($(this).html().replace('Hide', 'Show'));
    } else {
      target.show();
      $(this).html($(this).html().replace('Show', 'Hide'));
    }
    return false;
  });

  doContentLoaded();
    
})

function doContentLoaded()
{

  $("#content_browser.ajax > form").submit(function(){
    data = $(this).serialize();
    $("#content_browser .results").load(this.action, data);
    return false;
  });  

  $("#content_browser.ajax .tag_list a").ajaxGetLink($("#content_browser .results"));

  $("#content_browser.ajax .results form, #page_attachments form").ajaxForm();
  
  $('table.sortable').tableDnD({
    onDrop: function(table,rows){ 
      var i = 0;
      $(table.rows).each(function(){
        $(this).find('input.position').val(i);
        i++;
      });
    },
    serializeRegexp: /[^_]*$/ 
  }).find('input.position').hide();


  $.ui.dialog.defaults.bgiframe = true;
  $(".dialog").each(function(dialog){
    $(this).dialog({ autoOpen: false, resizeable: true, width: 400})
  });

  $('a.dialog_link').click(function(){
    $('#'+this.target).dialog('open');
    return false;
  })

  $('a.ajax_dialog_link').click(function(){
    $('#'+this.target).html(' ').load(this.href).dialog('open');
    return false;
  })

  $('.user_autocomplete').autocomplete(window['user_autocomplete_url']);

  $('.tags_autocomplete').autocomplete(window['tags_autocomplete_url'], {multiple: true, multipleSeparator: ' '});

}
