# Unit test configuration file for MessageLogger service:
# placeholder feature

import FWCore.ParameterSet.python.Config as cms

process = cms.Process("TEST")

import FWCore.Framework.python.test.cmsExceptionsFatal_cff
process.options = FWCore.Framework.python.test.cmsExceptionsFatal_cff.options

process.load("FWCore.MessageService.python.test.Services_cff")

process.MessageLogger = cms.Service("MessageLogger",
    u12_warnings = cms.untracked.PSet(
        threshold = cms.untracked.string('WARNING'),
        noTimeStamps = cms.untracked.bool(True)
    ),
    u12_placeholder = cms.untracked.PSet(
        placeholder = cms.untracked.bool(True)
    ),
    categories = cms.untracked.vstring('preEventProcessing'),
    destinations = cms.untracked.vstring('u12_warnings', 
        'u12_placeholder')
)

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(2)
)

process.source = cms.Source("EmptySource")

process.sendSomeMessages = cms.EDFilter("UnitTestClient_A")

process.p = cms.Path(process.sendSomeMessages)


