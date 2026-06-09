import { expect, test } from 'vitest'
import { page } from 'vitest/browser'

test('updates button text after a click', async () => {
  document.body.innerHTML = '<button type="button">Clicked 0 times</button>'

  const button = document.querySelector('button')
  button?.addEventListener('click', () => {
    button.textContent = 'Clicked 1 time'
  })

  await page.getByRole('button', { name: 'Clicked 0 times' }).click()

  await expect.element(page.getByRole('button')).toHaveTextContent('Clicked 1 time')
})
