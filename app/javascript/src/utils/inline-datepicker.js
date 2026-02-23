// Inline calendar widget — no dependencies.
// Renders into `container`, keeping `hiddenInput` (type=date, value=YYYY-MM-DD) in sync.
// Options: { firstDay: 1 }  — 0=Sunday, 1=Monday

export function inlineDatepicker(container, hiddenInput, options = {}) {
  const firstDay = options.firstDay ?? 1;

  function parseDate(str) {
    if (str && /^\d{4}-\d{2}-\d{2}$/.test(str)) {
      const [y, m, d] = str.split('-').map(Number);
      return new Date(y, m - 1, d);
    }
    const t = new Date();
    return new Date(t.getFullYear(), t.getMonth(), t.getDate());
  }

  let selected = parseDate(hiddenInput.value);
  let viewing = new Date(selected.getFullYear(), selected.getMonth(), 1);

  const DAY_NAMES_SHORT = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  const MONTH_NAMES = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  function pad(n) { return String(n).padStart(2, '0'); }
  function toYMD(date) {
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
  }
  function sameDay(a, b) {
    return a.getFullYear() === b.getFullYear() &&
           a.getMonth() === b.getMonth() &&
           a.getDate() === b.getDate();
  }

  container.className = 'idp-widget';

  function render() {
    const year = viewing.getFullYear();
    const month = viewing.getMonth();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const dayOrder = Array.from({ length: 7 }, (_, i) => (firstDay + i) % 7);
    const firstOfMonth = new Date(year, month, 1);
    const startOffset = (firstOfMonth.getDay() - firstDay + 7) % 7;
    const startDate = new Date(year, month, 1 - startOffset);

    let html = `<div class="idp-header">
      <a class="not-green idp-prev" aria-label="Previous month" href="#">&#8249;</a>
      <div class="idp-title"><span class="idp-month">${MONTH_NAMES[month]}</span>&nbsp;<span class="idp-year">${year}</span></div>
      <a class="not-green idp-next" aria-label="Next month" href="#">&#8250;</a>
    </div>`;

    html += `<table class="idp-table" role="grid">`;

    // Day-name headers
    html += '<thead><tr>';
    for (const dow of dayOrder) {
      html += `<th scope="col"><span title="${DAY_NAMES_SHORT[dow]}">${DAY_NAMES_SHORT[dow]}</span></th>`;
    }
    html += '</tr></thead><tbody>';

    // Only render weeks that contain at least one day in the current month
    const cursor = new Date(startDate);
    for (let week = 0; week < 6; week++) {
      const weekStart = new Date(cursor);
      const weekHasCurrentMonth = Array.from({ length: 7 }, (_, i) => {
        const d = new Date(weekStart);
        d.setDate(d.getDate() + i);
        return d.getMonth() === month;
      }).some(Boolean);
      if (!weekHasCurrentMonth) break;

      html += '<tr>';
      for (const dow of dayOrder) {
        void dow;
        const isOtherMonth = cursor.getMonth() !== month;
        const isToday = sameDay(cursor, today);
        const isSelected = sameDay(cursor, selected);
        const ymd = toYMD(cursor);
        if (isOtherMonth) {
          html += '<td>&nbsp;</td>';
        } else {
          let cls = '';
          if (isToday) cls += ' idp-today';
          if (isSelected) cls += ' idp-selected';
          html += `<td class="${cls.trim()}"><a class="not-green" data-date="${ymd}" href="#">${cursor.getDate()}</a></td>`;
        }
        cursor.setDate(cursor.getDate() + 1);
      }
      html += '</tr>';
    }

    html += '</tbody></table>';
    container.innerHTML = html;

    container.querySelector('.idp-prev').addEventListener('click', (e) => {
      e.preventDefault();
      viewing = new Date(viewing.getFullYear(), viewing.getMonth() - 1, 1);
      render();
    });
    container.querySelector('.idp-next').addEventListener('click', (e) => {
      e.preventDefault();
      viewing = new Date(viewing.getFullYear(), viewing.getMonth() + 1, 1);
      render();
    });
    container.querySelectorAll('.idp-table td a').forEach(a => {
      a.addEventListener('click', (e) => {
        e.preventDefault();
        selected = parseDate(a.dataset.date);
        hiddenInput.value = a.dataset.date;
        hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
        render();
      });
    });
  }

  render();
}
