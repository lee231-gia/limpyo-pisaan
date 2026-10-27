import { test } from 'node:test';
import assert from 'node:assert/strict';
test('reports reject whitespace-only required fields', async () => {
  const { validateReport } = await import('../core.js');
  assert.deepEqual(Object.keys(validateReport({type:'',location:' ',description:' '})), ['type','location','description']);
  assert.deepEqual(validateReport({type:'Illegal dumping',location:'Near the store',description:'Bags beside the road'}), {});
});
test('registration validates email, password length, and matching passwords', async () => {
  const { validateAccount } = await import('../core.js');
  const errors = validateAccount({name:'',email:'bad',password:'123',confirm:'456'});
  assert.deepEqual(Object.keys(errors), ['name','email','password','confirm']);
  assert.ok(validateAccount({name:'Nami',email:'nami@example.com',password:'',confirm:''}).confirm);
  assert.deepEqual(validateAccount({name:'Nami',email:'nami@example.com',password:'password1',confirm:'password1'}), {});
});
test('report references remain unique after reports are removed', async () => {
  const { nextReference } = await import('../core.js');
  assert.equal(nextReference([{id:'DEMO-LP-001'},{id:'DEMO-LP-004'}]), 'DEMO-LP-005');
});
