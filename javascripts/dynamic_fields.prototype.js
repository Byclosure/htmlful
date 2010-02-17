document.observe('click', function(event) {
  if (element = event.findElement('.remove_fieldset')) {
    // IE is not recognizing left click, but it's OK because it handles right clicks itself
    if (Prototype.Browser.IE || event.isLeftClick()) {
      element.up().previous().down('input[type=hidden]').value = 1;
      element.up('fieldset').hide();
      event.stop();
    }
  }
});

$$('form div.new_nested_element').each(function(element) {
  var create_button = element.down('a.create_element');
  var remove_button = element.down('a.remove_element').remove();
  var fragment = element.down('fieldset').remove();
  var remove_button_function = function(event) {
    // IE is not recognizing left click, but it's OK because it handles right clicks itself
    if (Prototype.Browser.IE || event.isLeftClick()) {
      this.up('fieldset').remove();
      event.stop(); 
    }
  }
  create_button.observe('click', function(event) {
    var new_fragment = fragment.cloneNode(true);
  
    var new_remove_button = remove_button.cloneNode(true);
    new_remove_button.observe('click', remove_button_function);
  
    var nested_inputs = create_button.up().down('div.nested_inputs');
    nested_inputs.insert(new_fragment);
  
    // this is a necessary hack for rails http://groups.google.com.au/group/formtastic/browse_thread/thread/9358a13bd26a6108
    var unique_id = new Date().getTime();
    new_fragment.select('input').each(function(e) {
      e.id = e.id && e.id.gsub(/NEW_RECORD/, unique_id);
      e.name = e.name && e.name.gsub(/NEW_RECORD/, unique_id);
    });
    new_fragment.select('label').each(function(e) {
      e.htmlFor = e.htmlFor && e.htmlFor.replace(/NEW_RECORD/, unique_id);
    });

    new_fragment.insert(new_remove_button);
    new_fragment.show();
    //this.up().insert({top: new_fragment.insert(new_remove_button)});
    event.stop();
  });
});