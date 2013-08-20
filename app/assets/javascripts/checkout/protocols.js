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
