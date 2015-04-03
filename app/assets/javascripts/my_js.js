$(function() {
  $( "#show_modal" ).click(function() {
    $('#about_modal').modal({
      keyboard: true
    });
  });

  $(".spotify_checkbox").change(function() {
    if(this.checked) {
      $(this).parents("tr").addClass("warning");
      $(this).parents("tr").children(".song_text").children().children("a").addClass("highlighted");
    } else if (this.checked === false) {
      $(this).parents("tr").removeClass("warning");
      $(this).parents("tr").children(".song_text").children().children("a").removeClass("highlighted");
    }
  });

  // $(".spotify_checkbox").click(function(){
  //     $(this).parents("tr").toggleClass('warning');
  //     $(this).parents("tr").children(".song_text").children().children("a").toggleClass("highlighted");
  // });

  $('#select_all').click(function(event) {  //on click 
    if(this.checked) { // check select status
      $('.spotify_checkbox').each(function() { //loop through each checkbox
        this.checked = true;  //select all checkboxes with class "checkbox1"
        $(this).parents("tr").addClass("warning");  
        $(this).parents("tr").children(".song_text").children().children("a").addClass("highlighted");           
      });
    }else{
      $('.spotify_checkbox').each(function() { //loop through each checkbox
        this.checked = false; //deselect all checkboxes with class "checkbox1"
        $(this).parents("tr").removeClass("warning");
        $(this).parents("tr").children(".song_text").children().children("a").removeClass("highlighted");                  
      });         
    }
  });
});