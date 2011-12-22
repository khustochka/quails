$(function() {
    var form = $('#new_comment').clone();

    $('.reply a').click( function() {
        $("#comment_parent_id", form).val($(this).data('comment-id'));
        form.attr('id', 'reply' + $(this).data('comment-id')).insertAfter($(this).closest(".reply"));
        return false;
    });

});