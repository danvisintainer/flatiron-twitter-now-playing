$(function() {
  $( "#show_modal" ).click(function() {
    $('#about_modal').modal({
      keyboard: true
    });
  });

  $(".spotify_checkbox").change(function() {
    if(this.checked) {
      console.log("Checked");
    }
  });

  $('#select_all').click(function(event) {  //on click 
    if(this.checked) { // check select status
      $('.spotify_checkbox').each(function() { //loop through each checkbox
        this.checked = true;  //select all checkboxes with class "checkbox1"               
      });
    }else{
      $('.spotify_checkbox').each(function() { //loop through each checkbox
        this.checked = false; //deselect all checkboxes with class "checkbox1"                       
      });         
    }
  });
});