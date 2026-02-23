document.addEventListener('DOMContentLoaded', function () {
  if (!document.querySelector('[data-flickr-search]')) return;

  const flickrForm = document.querySelector('[data-flickr-search]');
  const spinner = document.getElementById('spinner');
  const result = document.querySelector('.flickr_result');

  spinner.hidden = true;

  flickrForm.addEventListener('ajax:send', function () {
    result.innerHTML = '';
    spinner.hidden = false;
  });

  flickrForm.addEventListener('ajax:success', function (e) {
    spinner.hidden = true;
    result.innerHTML = e.detail[0].body.innerHTML;
  });
});
