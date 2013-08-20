//= require checkout/subform

document.observe("dom:loaded", function() {
  /* update the checkout URL if clicked on a protocol */
  var protocols = $('checkout_protocols')
  if (!protocols) {
    return;
  }
  protocols.select('a').each(function(e) {
    e.observe('click', function(event) {
      $('checkout_url').value = checkout_commands.get(this.id);
      $('checkout_protocols').select('a').each(function(e) {
        e.removeClassName("selected");
      });
      this.addClassName("selected")

      var access = $('checkout_access');
      if (access) {
        var value = window.checkout_access.get(this.id);
        access.innerHTML = value;
      }

      event.stop();
    });
  });
  /* select the text field contents if activated */
  Event.observe('checkout_url', 'click', function(event) {
    this.activate();
  });
});

jQuery(document).ready(function() {
  var defaultCheckboxes = jQuery('.checkout_protocol_table .protocol_is_default input[type=checkbox]');

  defaultCheckboxes.live('click', function(event){
    var currentCheckbox = event.target;
    var checkBoxesinCurrentTable = jQuery(currentCheckbox).parentsUntil('table').find('.protocol_is_default input[type=checkbox]')
    checkBoxesinCurrentTable.each(function(){
      if (this != currentCheckbox) {
        jQuery(this).attr('checked', false);
      }
    });
  });
});
