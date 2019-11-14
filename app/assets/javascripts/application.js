const search = document.querySelector('[data-id=version-search]')
const sidebar = document.querySelector('#sidebar')
let id = null

if (search) {
  search.addEventListener('input', () => {
    clearTimeout(id)
    id = setTimeout(async () => {
      const a = document.createElement('a')
      a.href = window.location.toString()

      if (search.value.trim() !== "") {
        a.search = `search=${search.value}`
      } else {
        a.search = ''
      }

      const response = await fetch(a.href, {
        headers: { "Accept": "application/javascript" }
      })

      const html = await response.text()

      sidebar.innerHTML = html

      history.replaceState({}, document.title, a.href)
    }, 300)
  })
}
