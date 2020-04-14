const fetch = require("node-fetch");
const chai = require('chai');
const chaiHttp = require('chai-http');
const sleep = require('util').promisify(setTimeout);

chai.use(chaiHttp);
const expect = chai.expect;

const url = `https://${process.env.ENDPOINT}`;
describe('employee api', () => {
    it('should create/update/delete an employee', async () => {
        let id = await chai.request(url)
            .post('/employees')
            .send({
                name: 'test'
            })
            .then((response) => {
                expect(response).to.have.status(200);
                return response.body.id;
            });
        await sleep(1000);
        await chai.request(url)
            .get(`/employees/${id}`)
            .then((response) => {
                expect(response).to.have.status(200);
                let body = response.body;
                console.log(body);
                expect(body.name).to.equal('test');
            });

        await chai.request(url)
            .put(`/employees`)
            .send({
                id,
                name: 'test-updated'
            })
            .then((response) => {
                expect(response).to.have.status(200);
            });

        await chai.request(url)
            .get(`/employees/${id}`)
            .then((response) => {
                expect(response).to.have.status(200);
                let body = response.body;
                console.log(body);
                expect(body.name).to.equal('test-updated');
            });

        await chai.request(url)
            .delete(`/employees/${id}`)
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response.body.success).to.equal(true);
            });

    });
});