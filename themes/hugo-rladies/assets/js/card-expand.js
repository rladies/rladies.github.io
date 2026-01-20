$('.card-expand').hover(function() {
$(this).find('.card-expand-animate').stop().animate({
    height: "toggle",
    opacity: "toggle"
    }, 300);
});