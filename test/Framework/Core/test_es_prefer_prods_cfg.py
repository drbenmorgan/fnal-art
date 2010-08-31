import FWCore.ParameterSet.python.Config as cms

process = cms.Process("TEST")

process.load("FWCore.Framework.python.test.cmsExceptionsFatal_cff")

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(5)
)

process.source = cms.Source("EmptySource")

process.m = cms.EDAnalyzer("TestESDummyDataAnalyzer",
    expected = cms.int32(5)
)

process.LoadableDummyProvider = cms.ESProducer("LoadableDummyProvider",
    value = cms.untracked.int32(5)
)

process.bad = cms.ESProducer("LoadableDummyProvider",
    value = cms.untracked.int32(0)
)

process.prefer("LoadableDummyProvider")
process.LoadableDummyESSource = cms.ESSource("LoadableDummyESSource")

process.p1 = cms.Path(process.m)


