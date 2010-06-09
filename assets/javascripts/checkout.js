document.observe("dom:loaded", function() {
  /* update the checkout URL if clicked on a protocol */
  $('checkout_protocols').select('a').each(function(e) {
    e.observe('click', function(event) {
      $('checkout_url').value = this.href;
      $('checkout_protocols').select('a').each(function(e) {
        e.removeClassName("selected");
      });
      this.addClassName("selected")
      
      var value = checkout_access.get(this.id);
      $('checkout_access').innerHTML = value;
      
      event.stop();
    });
  });
  /* select the text field contents if activated */
  Event.observe('checkout_url', 'click', function(event) {
   this.focus();
   this.select();
  });
});