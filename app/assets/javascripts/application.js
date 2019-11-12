const search = document.querySelector('[data-id=version-search]')

if (search) {
  search.addEventListener('input', () => {
    if (search.value.trim() === "") {
     for (const item of document.querySelectorAll('[data-id=version-item]')) {
       item.querySelector('[data-id=version-entities]').style.display = "none"
       item.style.display = "block"
     }
    } else {
      const regexp = new RegExp(search.value, 'i')

      for (const item of document.querySelectorAll('[data-id=version-item]')) {
        let nameMatched = item.querySelector('a').textContent.match(regexp);
        let itemsMatched = false

        for (const entity of item.querySelectorAll('[data-id=version-entity]')) {
          if (entity.textContent.match(regexp)) {
            entity.style.display = "block"
            itemsMatched = true
          } else {
            entity.style.display = "none"
          }
        }

        item.querySelector('[data-id=version-entities]').style.display = itemsMatched ? "block" : "none"
        item.style.display = nameMatched || itemsMatched ? "block" : "none"
      }
    }
  })
}
