from Mixins import PrintOptions, _SimpleParameterTypeBase, _ParameterTypeBase, _Parameterizable, _ConfigureComponent, _Labelable, _TypedParameterizable, _Unlabelable
from Mixins import _ValidatingParameterListBase
from ExceptionHandling import format_typename, format_outerframe

import codecs
import copy
_string_escape_encoder = codecs.getencoder('string_escape')

class _Untracked(object):
    """Class type for 'untracked' to allow nice syntax"""
    __name__ = "untracked"
    @staticmethod
    def __call__(param):
        """used to set a 'param' parameter to be 'untracked'"""
        param.setIsTracked(False)
        return param
    def __getattr__(self,name):
        """A factory which allows syntax untracked.name(value) to construct an
        instance of 'name' class which is set to be untracked"""
        if name == "__bases__": raise AttributeError  # isclass uses __bases__ to recognize class objects
        class Factory(object):
            def __init__(self,name):
                self.name = name
            def __call__(self,*value,**params):
                param = globals()[self.name](*value,**params)
                return _Untracked.__call__(param)
        return Factory(name)

untracked = _Untracked()


class int32(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        return isinstance(value,int)
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        if len(value) >1 and '0x' == value[:2]:
            return int32(int(value,16))
        return int32(int(value))
    def insertInto(self, parameterSet, myname):
        parameterSet.addInt32(self.isTracked(), myname, self.value())


class uint32(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        return ((isinstance(value,int) and value >= 0) or
                (isinstance(value,long) and value >= 0) and value <= 0xFFFFFFFF)
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        if len(value) >1 and '0x' == value[:2]:
            return uint32(long(value,16))
        return uint32(long(value))
    def insertInto(self, parameterSet, myname):
        parameterSet.addUInt32(self.isTracked(), myname, self.value())



class int64(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        return isinstance(value,int) or (
            isinstance(value,long) and
            (-0x7FFFFFFFFFFFFFFF < value <= 0x7FFFFFFFFFFFFFFF) )
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        if len(value) >1 and '0x' == value[:2]:
            return uint32(long(value,16))
        return int64(long(value))
    def insertInto(self, parameterSet, myname):
        parameterSet.addInt64(self.isTracked(), myname, self.value())



class uint64(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        return ((isinstance(value,int) and value >= 0) or
                (isinstance(value,long) and value >= 0) and value <= 0xFFFFFFFFFFFFFFFF)
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        if len(value) >1 and '0x' == value[:2]:
            return uint32(long(value,16))
        return uint64(long(value))
    def insertInto(self, parameterSet, myname):
        parameterSet.addUInt64(self.isTracked(), myname, self.value())



class double(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        try:
            tmp = float(value)
            return True
        except:
            return False
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        return double(float(value))
    def insertInto(self, parameterSet, myname):
        parameterSet.addDouble(self.isTracked(), myname, float(self.value()))


import __builtin__
class bool(_SimpleParameterTypeBase):
    @staticmethod
    def _isValid(value):
        return (isinstance(value,type(False)) or isinstance(value(type(True))))
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        if value.lower() in ('true', 't', 'on', 'yes', '1'):
            return bool(True)
        if value.lower() in ('false','f','off','no', '0'):
            return bool(False)
        try:
            return bool(__builtin__.bool(eval(value)))
        except:
            pass
        raise RuntimeError('can not make bool from string '+value)
    def insertInto(self, parameterSet, myname):
        parameterSet.addBool(self.isTracked(), myname, self.value())



class string(_SimpleParameterTypeBase):
    def __init__(self,value):
        super(string,self).__init__(value)
    @staticmethod
    def _isValid(value):
        return isinstance(value,type(''))
    def configValue(self, options=PrintOptions()):
        return self.formatValueForConfig(self.value())
    def pythonValue(self, options=PrintOptions()):
        return self.configValue(options)
    @staticmethod
    def formatValueForConfig(value):
        l = len(value)
        value,newL = _string_escape_encoder(value)
        if l != newL:
            #get rid of the hex encoding
            value=value.replace('\\x0','\\')
        if "'" in value:
            return '"'+value+'"'
        return "'"+value+"'"
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        return string(value)
    def insertInto(self, parameterSet, myname):
        value = self.value()
        #  doesn't seem to handle \0 correctly
        #if value == '\0':
        #    value = ''
        parameterSet.addString(self.isTracked(), myname, value)


class EventID(_ParameterTypeBase):
    def __init__(self, run, ev):
        super(EventID,self).__init__()
        self.__run = run
        self.__event = ev
    def run(self):
        return self.__run
    def event(self):
        return self.__event
    @staticmethod
    def _isValid(value):
        return True
    @staticmethod
    def _valueFromString(value):
        parts = value.split(":")
        return EventID(int(parts[0]), int(parts[1]))
    def pythonValue(self, options=PrintOptions()):
        return str(self.__run)+ ', '+str(self.__event)
    def cppID(self, parameterSet):
        return parameterSet.newEventID(self.run(), self.event())
    def insertInto(self, parameterSet, myname):
        parameterSet.addEventID(self.isTracked(), myname, self.cppID(parameterSet))


class SubRunID(_ParameterTypeBase):
    def __init__(self, run, block):
        super(SubRunID,self).__init__()
        self.__run = run
        self.__block = block
    def run(self):
        return self.__run
    def luminosityBlock(self):
        return self.__block
    @staticmethod
    def _isValid(value):
        return True
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        parts = value.split(":")
        return SubRunID(int(parts[0]), int(parts[1]))
    def pythonValue(self, options=PrintOptions()):
          return str(self.__run)+ ', '+str(self.__block)
    def cppID(self, parameterSet):
        return parameterSet.newSubRunID(self.run(), self.luminosityBlock())
    def insertInto(self, parameterSet, myname):
        parameterSet.addSubRunID(self.isTracked(), myname, self.cppID(parameterSet))


class CmsRange(_ParameterTypeBase):
    def __init__(self, start, startSub, end, endSub):
        super(CmsRange,self).__init__()
        self.__start    = start
        self.__startSub = startSub
        self.__end      = end
        self.__endSub   = endSub
    def start(self):
        return self.__start
    def startSub(self):
        return self.__startSub
    def end(self):
        return self.__end
    def endSub(self):
        return self.__startSub
    @staticmethod
    def _isValid(value):
        return True
    @staticmethod
    def _valueFromString(value):
        """only used for cfg-parsing"""
        value = value.replace(' ','')
        parts = value.split("-")
        startParts = parts[0].split(":")
        endParts   = parts[1].split(":")
        if startParts[1].lower() == "max":
            startParts[1] = "0"
        if startParts[1].lower() == "min":
            startParts[1] = "1"
        if endParts[1].lower() == "max":
            endParts[1] = "0"
        if endParts[1].lower() == "min":
            endParts[1] = "1"
        return CmsRange(int(startParts[0]), int(startParts[1]),
                        int(endParts[0]), int(endParts[1]))
    def pythonValue(self, options=PrintOptions()):
          return str(self.__start) + ', ' + str(self.__startSub) + ', ' \
               + str(self.__end)   + ', ' + str(self.__endSub)
    def cppID(self, parameterSet):
        return parameterSet.newCmsRange(self.start(), self.startSub(),self.end(), self.endSub())
    def insertInto(self, parameterSet, myname):
        parameterSet.addCmsRange(self.isTracked(), myname, self.cppID(parameterSet))


class InputTag(_ParameterTypeBase):
    def __init__(self,moduleLabel,productInstanceLabel='',processName=''):
        super(InputTag,self).__init__()
        self._setValues(moduleLabel, productInstanceLabel, processName)
    def getModuleLabel(self):
        return self.__moduleLabel
    def setModuleLabel(self,label):
        self.__moduleLabel = label
    moduleLabel = property(getModuleLabel,setModuleLabel,"module label for the product")
    def getProductInstanceLabel(self):
        return self.__productInstance
    def setProductInstanceLabel(self,label):
        self.__productInstance = label
    productInstanceLabel = property(getProductInstanceLabel,setProductInstanceLabel,"product instance label for the product")
    def getProcessName(self):
        return self.__processName
    def setProcessName(self,label):
        self.__processName = label
    processName = property(getProcessName,setProcessName,"process name for the product")
    def configValue(self, options=PrintOptions()):
        result = self.__moduleLabel
        if self.__productInstance != "" or self.__processName != "":
            result += ':' + self.__productInstance
        if self.__processName != "":
            result += ':' + self.__processName
        if result == "":
            result = '\"\"'
        return result;
    def pythonValue(self, options=PrintOptions()):
        cfgValue = self.configValue(options)
        # empty strings already have quotes
        if cfgValue == '\"\"':
            return cfgValue
        colonedValue = "\""+cfgValue+"\""
        # change label:instance:process to "label","instance","process"
        return colonedValue.replace(":","\",\"")
    @staticmethod
    def _isValid(value):
        return True
    def __cmp__(self,other):
        v = self.__moduleLabel <> other.__moduleLabel
        if not v:
            v= self.__productInstance <> other.__productInstance
            if not v:
                v=self.__processName <> other.__processName
        return v
    def value(self):
        "Return the string rep"
        return self.configValue()
    @staticmethod
    def formatValueForConfig(value):
        return value.configValue()
    @staticmethod
    def _valueFromString(string):
        parts = string.split(":")
        return InputTag(*parts)
    def setValue(self,v):
        self._setValues(v)
    def _setValues(self,moduleLabel,productInstanceLabel='',processName=''):
        self.__moduleLabel = moduleLabel
        self.__productInstance = productInstanceLabel
        self.__processName=processName

        if -1 != moduleLabel.find(":"):
        #    raise RuntimeError("the module label '"+str(moduleLabel)+"' contains a ':'. If you want to specify more than one label, please pass them as separate arguments.")
        # tolerate it, at least for the translation phase
            toks = moduleLabel.split(":")
            self.__moduleLabel = toks[0]
            if len(toks) > 1:
               self.__productInstance = toks[1]
            if len(toks) > 2:
               self.__processName=toks[2]

    # convert to the wrapper class for C++ InputTags
    def cppTag(self, parameterSet):
        return parameterSet.newInputTag(self.getModuleLabel(),
                                        self.getProductInstanceLabel(),
                                        self.getProcessName())
    def insertInto(self, parameterSet, myname):
        parameterSet.addInputTag(self.isTracked(), myname, self.cppTag(parameterSet))

class FileInPath(_SimpleParameterTypeBase):
    def __init__(self,value):
        super(FileInPath,self).__init__(value)
    @staticmethod
    def _isValid(value):
        return True
    def configValue(self, options=PrintOptions()):
        return string.formatValueForConfig(self.value())
    @staticmethod
    def formatValueForConfig(value):
        return string.formatValueForConfig(value)
    @staticmethod
    def _valueFromString(value):
        return FileInPath(value)
    def insertInto(self, parameterSet, myname):
      parameterSet.addNewFileInPath( self.isTracked(), myname, self.value() )

class SecSource(_ParameterTypeBase,_TypedParameterizable,_ConfigureComponent,_Labelable):
    def __init__(self,type_,*arg,**args):
        _ParameterTypeBase.__init__(self)
        _TypedParameterizable.__init__(self,type_,*arg,**args)
    def value(self):
        return self
    @staticmethod
    def _isValid(value):
        return True
    def configTypeName(self):
        return "secsource"
    def configValue(self, options=PrintOptions()):
       return self.dumpConfig(options)
    def dumpPython(self, options=PrintOptions()):
        return "cms.SecSource(\""+self.type_()+"\",\n"+_Parameterizable.dumpPython(self, options)+options.indentation()+")"
    def copy(self):
        # TODO is the one in TypedParameterizable better?
        return copy.copy(self)
    def _place(self,name,proc):
        proc._placePSet(name,self)
    def __str__(self):
        return object.__str__(self)

class PSet(_ParameterTypeBase,_Parameterizable,_ConfigureComponent,_Labelable):
    def __init__(self,*arg,**args):
        #need to call the inits separately
        _ParameterTypeBase.__init__(self)
        _Parameterizable.__init__(self,*arg,**args)
    def value(self):
        return self
    @staticmethod
    def _isValid(value):
        return True

    def configValue(self, options=PrintOptions()):
        config = '{ \n'
        for name in self.parameterNames_():
            param = getattr(self,name)
            options.indent()
            config+=options.indentation()+param.configTypeName()+' '+name+' = '+param.configValue(options)+'\n'
            options.unindent()
        config += options.indentation()+'}\n'
        return config
    def dumpPython(self, options=PrintOptions()):
        return self.pythonTypeName()+"(\n"+_Parameterizable.dumpPython(self, options)+options.indentation()+")"
    def clone(self, *args, **params):
        myparams = self.parameters_()
        if len(params):
            #need to treat items both in params and myparams specially
            for key,value in params.iteritems():
                if key in myparams:
                    if isinstance(value,_ParameterTypeBase):
                        myparams[key] =value
                    else:
                        myparams[key].setValue(value)
                else:
                    if isinstance(value,_ParameterTypeBase):
                        myparams[key]=value
                    else:
                        self._Parameterizable__raiseBadSetAttr(key)

        returnValue = PSet(**myparams)
        returnValue._isModified = False
        returnValue._isFrozen = False
        return returnValue
    def copy(self):
        return copy.copy(self)
    def _place(self,name,proc):
        proc._placePSet(name,self)
    def __str__(self):
        return object.__str__(self)
    def insertInto(self, parameterSet, myname):
        newpset = parameterSet.newPSet()
        self.insertContentsInto(newpset)
        parameterSet.addPSet(self.isTracked(), myname, newpset)


class vint32(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vint32,self).__init__(*arg,**args)

    @staticmethod
    def _itemIsValid(item):
        return int32._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vint32(*_ValidatingParameterListBase._itemsFromStrings(value,int32._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVInt32(self.isTracked(), myname, self.value())



class vuint32(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vuint32,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return uint32._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vuint32(*_ValidatingParameterListBase._itemsFromStrings(value,uint32._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVUInt32(self.isTracked(), myname, self.value())



class vint64(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vint64,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return int64._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vint64(*_ValidatingParameterListBase._itemsFromStrings(value,int64._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVInt64(self.isTracked(), myname, self.value())



class vuint64(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vuint64,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return uint64._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vuint64(*_ValidatingParameterListBase._itemsFromStrings(value,vuint64._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVUInt64(self.isTracked(), myname, self.value())



class vdouble(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vdouble,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return double._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vdouble(*_ValidatingParameterListBase._itemsFromStrings(value,double._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVDouble(self.isTracked(), myname, self.value())



class vbool(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vbool,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return bool._isValid(item)
    @staticmethod
    def _valueFromString(value):
        return vbool(*_ValidatingParameterListBase._itemsFromStrings(value,bool._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVBool(self.isTracked(), myname, self.value())



class vstring(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(vstring,self).__init__(*arg,**args)
        self._nPerLine = 1
    @staticmethod
    def _itemIsValid(item):
        return string._isValid(item)
    def configValueForItem(self,item,options):
        return string.formatValueForConfig(item)
    @staticmethod
    def _valueFromString(value):
        return vstring(*_ValidatingParameterListBase._itemsFromStrings(value,string._valueFromString))
    def insertInto(self, parameterSet, myname):
        parameterSet.addVString(self.isTracked(), myname, self.value())

class VSubRunID(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(VSubRunID,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return SubRunID._isValid(item)
    def configValueForItem(self,item,options):
        return SubRunID.formatValueForConfig(item)
    def pythonValueForItem(self,item, options):
        return item.dumpPython(options)
    @staticmethod
    def _valueFromString(value):
        return VSubRunID(*_ValidatingParameterListBase._itemsFromStrings(value,SubRunID._valueFromString))
    def insertInto(self, parameterSet, myname):
        cppIDs = list()
        for i in self:
            item = i
            if isinstance(item, str):
                item = SubRunID._valueFromString(item)
            cppIDs.append(item.cppID(parameterSet))
        parameterSet.addVSubRunID(self.isTracked(), myname, cppIDs)


class VInputTag(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(VInputTag,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return InputTag._isValid(item)
    def configValueForItem(self,item,options):
       # we tolerate strings as members
       if isinstance(item, str):
         return '"'+item+'"'
       else:
         return InputTag.formatValueForConfig(item)
    def pythonValueForItem(self,item, options):
        # we tolerate strings as members
        if isinstance(item, str):
            return '"'+item+'"'
        else:
            return item.dumpPython(options)
    @staticmethod
    def _valueFromString(value):
        return VInputTag(*_ValidatingParameterListBase._itemsFromStrings(value,InputTag._valueFromString))
    def insertInto(self, parameterSet, myname):
        cppTags = list()
        for i in self:
            item = i
            if isinstance(item, str):
                item = InputTag(i)
            cppTags.append(item.cppTag(parameterSet))
        parameterSet.addVInputTag(self.isTracked(), myname, cppTags)

class VEventID(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(VEventID,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return EventID._isValid(item)
    def configValueForItem(self,item,options):
        return EventID.formatValueForConfig(item)
    def pythonValueForItem(self,item, options):
        # we tolerate strings as members
        if isinstance(item, str):
            return '"'+item+'"'
        else:
            return item.dumpPython(options)
    @staticmethod
    def _valueFromString(value):
        return VEventID(*_ValidatingParameterListBase._itemsFromStrings(value,EventID._valueFromString))
    def insertInto(self, parameterSet, myname):
        cppIDs = list()
        for i in self:
            item = i
            if isinstance(item, str):
                item = EventID._valueFromString(item)
            cppIDs.append(item.cppID(parameterSet))
        parameterSet.addVEventID(self.isTracked(), myname, cppIDs)


class VCmsRange(_ValidatingParameterListBase):
    def __init__(self,*arg,**args):
        super(VCmsRange,self).__init__(*arg,**args)
    @staticmethod
    def _itemIsValid(item):
        return CmsRange._isValid(item)
    def configValueForItem(self,item,options):
        return CmsRange.formatValueForConfig(item)
    def pythonValueForItem(self,item, options):
        return item.dumpPython(options)
    @staticmethod
    def _valueFromString(value):
        return VCmsRange(*_ValidatingParameterListBase._itemsFromStrings(value,VCmsRange._valueFromString))
    def insertInto(self, parameterSet, myname):
        cppIDs = list()
        for i in self:
            item = i
            if isinstance(item, str):
                item = CmsRange._valueFromString(item)
            cppIDs.append(item.cppID(parameterSet))
        parameterSet.addVCmsRange(self.isTracked(), myname, cppIDs)


class VPSet(_ValidatingParameterListBase,_ConfigureComponent,_Labelable):
    def __init__(self,*arg,**args):
        super(VPSet,self).__init__(*arg,**args)
        self._nPerLine = 1
    @staticmethod
    def _itemIsValid(item):
        return isinstance(item, PSet) and PSet._isValid(item)
    def configValueForItem(self,item, options):
        return PSet.configValue(item, options)
    def pythonValueForItem(self,item, options):
        return PSet.dumpPython(item,options)
    def copy(self):
        return copy.copy(self)
    def _place(self,name,proc):
        proc._placeVPSet(name,self)
    def insertInto(self, parameterSet, myname):
        # translate the PSet members into C++ parameterSets
        parametersets = list()
        for pset in self:
            newparameterset = parameterSet.newPSet()
            pset.insertContentsInto(newparameterset)
            parametersets.append(newparameterset)
        parameterSet.addVPSet(self.isTracked(), myname, parametersets)
    def __repr__(self):
        return self.dumpPython()


if __name__ == "__main__":

    import unittest
    class PSetTester(object):
        def addEventID(self,*pargs,**kargs):
            pass
        def newEventID(self,*pargs,**kargs):
            pass
        def addVEventID(self,*pargs,**kargs):
            pass
        def newSubRunID(self,*pargs,**kargs):
            pass
        def addSubRunID(self,*pargs,**kargs):
            pass
        def addVSubRunID(self,*pargs,**kargs):
            pass
        def addCmsRange(self,*pargs,**kargs):
            pass
        def newCmsRange(self,*pargs,**kargs):
            pass
        def addVCmsRange(self,*pargs,**kargs):
            pass
        def newVCmsRange(self,*pargs,**kargs):
            pass
    class testTypes(unittest.TestCase):
        def testint32(self):
            i = int32(1)
            self.assertEqual(i.value(),1)
            self.assertRaises(ValueError,int32,"i")
            i = int32._valueFromString("0xA")
            self.assertEqual(i.value(),10)

        def testuint32(self):
            i = uint32(1)
            self.assertEqual(i.value(),1)
            i = uint32(0)
            self.assertEqual(i.value(),0)
            self.assertRaises(ValueError,uint32,"i")
            self.assertRaises(ValueError,uint32,-1)
            i = uint32._valueFromString("0xA")
            self.assertEqual(i.value(),10)

        def testvint32(self):
            v = vint32()
            self.assertEqual(len(v),0)
            v.append(1)
            self.assertEqual(len(v),1)
            self.assertEqual(v[0],1)
            v.append(2)
            v.insert(1,3)
            self.assertEqual(v[1],3)
            v[1]=4
            self.assertEqual(v[1],4)
            v[1:1]=[5]
            self.assertEqual(len(v),4)
            self.assertEqual([1,5,4,2],list(v))
            self.assertEqual(repr(v), "cms.vint32(1, 5, 4, 2)")
            self.assertRaises(TypeError,v.append,('blah'))
        def testbool(self):
            b = bool(True)
            self.assertEqual(b.value(),True)
            b = bool(False)
            self.assertEqual(b.value(),False)
            b = bool._valueFromString("2")
            self.assertEqual(b.value(),True)
            self.assertEqual(repr(b), "cms.bool(True)")
        def testString(self):
            s=string('this is a test')
            self.assertEqual(s.value(),'this is a test')
            self.assertEqual(repr(s), "cms.string(\'this is a test\')")
            s=string('\0')
            self.assertEqual(s.value(),'\0')
            self.assertEqual(s.configValue(),"'\\0'")
            s2=string('')
            self.assertEqual(s2.value(),'')
        def testvstring(self):
            a = vstring("", "Barack", "John", "Sarah", "Joe")
            self.assertEqual(len(a), 5)
            self.assertEqual(a[0], "")
            self.assertEqual(a[3], "Sarah")
        def testUntracked(self):
            p=untracked(int32(1))
            self.assertRaises(TypeError,untracked,(1),{})
            self.failIf(p.isTracked())
            p=untracked.int32(1)
            self.assertEqual(repr(p), "cms.untracked.int32(1)")
            self.assertRaises(TypeError,untracked,(1),{})
            self.failIf(p.isTracked())
            p=untracked.vint32(1,5,3)
            self.assertRaises(TypeError,untracked,(1,5,3),{})
            self.failIf(p.isTracked())
            p = untracked.PSet(b=int32(1))
            self.failIf(p.isTracked())
            self.assertEqual(p.b.value(),1)
        def testInputTag(self):
            it = InputTag._valueFromString("label::proc")
            print it.pythonValue()
            self.assertEqual(it.getModuleLabel(), "label")
            self.assertEqual(it.getProductInstanceLabel(), "")
            self.assertEqual(it.getProcessName(), "proc")
            # tolerate, at least for translation phase
            #self.assertRaises(RuntimeError, InputTag,'foo:bar')
            it=InputTag('label',processName='proc')
            self.assertEqual(it.getModuleLabel(), "label")
            self.assertEqual(it.getProductInstanceLabel(), "")
            self.assertEqual(it.getProcessName(), "proc")
            self.assertEqual(repr(it), "cms.InputTag(\"label\",\"\",\"proc\")")
            vit = VInputTag(InputTag("label1"), InputTag("label2"))
            self.assertEqual(repr(vit), "cms.VInputTag(cms.InputTag(\"label1\"), cms.InputTag(\"label2\"))")
            vit = VInputTag("label1", "label2:label3")
            self.assertEqual(repr(vit), "cms.VInputTag(\"label1\", \"label2:label3\")")

        def testPSet(self):
            p1 = PSet(anInt = int32(1), a = PSet(b = int32(1)))
            self.assertRaises(ValueError, PSet, "foo")
            self.assertRaises(TypeError, PSet, foo = "bar")
            self.assertEqual(repr(p1), "cms.PSet(\n    a = cms.PSet(\n        b = cms.int32(1)\n    ),\n    anInt = cms.int32(1)\n)")
            vp1 = VPSet(PSet(i = int32(2)))
            #self.assertEqual(vp1.configValue(), "
            self.assertEqual(repr(vp1), "cms.VPSet(cms.PSet(\n    i = cms.int32(2)\n))")
            self.assert_(p1.hasParameter(['a', 'b']))
            self.failIf(p1.hasParameter(['a', 'c']))
            self.assertEqual(p1.getParameter(['a', 'b']).value(), 1)

        def testFileInPath(self):
            f = FileInPath("FWCore/ParameterSet/python/Types.py")
            self.assertEqual(f.configValue(), "'FWCore/ParameterSet/python/Types.py'")
        def testSecSource(self):
            s1 = SecSource("PoolSource", fileNames = vstring("foo.root"))
            self.assertEqual(s1.type_(), "PoolSource")
            self.assertEqual(s1.configValue(),
"""PoolSource { """+"""
    vstring fileNames = {
        'foo.root'
    }

}
""")
            s1=SecSource("PoolSource",type=int32(1))
            self.assertEqual(s1.type.value(),1)
        def testEventID(self):
            eid = EventID(2, 3)
            self.assertEqual( repr(eid), "cms.EventID(2, 3)" )
            pset = PSetTester()
            eid.insertInto(pset,'foo')
            eid2 = EventID._valueFromString('3:4')
            eid2.insertInto(pset,'foo2')
        def testVEventID(self):
            veid = VEventID(EventID(2, 3))
            veid2 = VEventID("1:2", "3:4")
            self.assertEqual( repr(veid[0]), "cms.EventID(2, 3)" )
            self.assertEqual( repr(veid2[0]), "'1:2'" )
            self.assertEqual( veid2.dumpPython(), 'cms.VEventID("1:2", "3:4")')
            pset = PSetTester()
            veid.insertInto(pset,'foo')

        def testSubRunID(self):
            lid = SubRunID(2, 3)
            self.assertEqual( repr(lid), "cms.SubRunID(2, 3)" )
            pset = PSetTester()
            lid.insertInto(pset,'foo')
            lid2 = SubRunID._valueFromString('3:4')
            lid2.insertInto(pset,'foo2')

        def testVSubRunID(self):
            vlid = VSubRunID(SubRunID(2, 3))
            vlid2 = VSubRunID("1:2", "3:4")
            self.assertEqual( repr(vlid[0]), "cms.SubRunID(2, 3)" )
            self.assertEqual( repr(vlid2[0]), "'1:2'" )
            pset = PSetTester()
            vlid.insertInto(pset,'foo')

        def testCmsRange(self):
            range1 = CmsRange(1, 2, 3, 4)
            range2 = CmsRange._valueFromString("1:2 - 3:4")
            range3 = CmsRange._valueFromString("1:MIN - 3:MAX")
            self.assertEqual(repr(range1), repr(range1))
            self.assertEqual(repr(range3), "cms.CmsRange(1, 1, 3, 0)")
            pset = PSetTester()
            range1.insertInto(pset,'foo')
            range2.insertInto(pset,'bar')
        def testVCmsRange(self):
            v1 = VCmsRange(CmsRange(1, 2, 3, 4))
            v2 = VCmsRange("1:2-3:4", "5:MIN-7:MAX")
            self.assertEqual( repr(v1[0]), "cms.CmsRange(1, 2, 3, 4)" )
            pset = PSetTester()
            v2.insertInto(pset,'foo')

    unittest.main()
