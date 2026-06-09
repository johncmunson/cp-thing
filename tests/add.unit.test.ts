import { expect, test } from 'vitest'

import { add } from '../lib/add'

test('adds two numbers', () => {
  expect(add(1, 2)).toBe(3)
})
