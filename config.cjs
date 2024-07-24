module.exports = {
  parserOpts: {
    mergePattern: /^Merged in (.*) \(pull request #(.*)\)$/,
    mergeCorrespondence: ["source", "id"],
  },
};
