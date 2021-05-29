#pragma once

#ifdef __cplusplus
#ifdef KURIOS_COMMAND_LIB_EXPORTS
#define COMMANDLIB_API extern "C" long __declspec( dllexport )
#else
#define COMMANDLIB_API extern "C" long __declspec( dllimport )
#endif
#else
#define COMMANDLIB_API 
#endif
/// <summary>
/// list all the possible port on this computer.
/// </summary>
/// <param name="serialNo">port list returned string include serial number and device descriptor, separated by comma</param>
/// <returns>non-negtive number: number of device in the list; negtive number : failed.</returns>
COMMANDLIB_API int common_List(unsigned char* serialNo);

/// <summary>
///  open port function.
/// </summary>
/// <param name="serialNo">serial number of the device to be opened, use GetPorts function to get exist list first.</param>
/// <param name="nBaud">bit per second of port</param>
/// <param name="timeout">set timeout value in (s)</param>
/// <returns> non-negtive number: hdl number returned successfully; negtive number : failed.</returns>
COMMANDLIB_API int common_Open(char* serialNo, int nBaud, int timeout);

/// <summary>
/// check opened status of port
/// </summary>
/// <param name="serialNo">serial number of the device to be checked.</param>
/// <returns> 0: port is not opened; 1: port is opened.</returns>
COMMANDLIB_API int common_IsOpen(char* serialNo);

/// <summary>
/// close current opened port
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int common_Close(int hdl);

/// <summary>
/// Returns the model number, hardware and firmware versions.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">the model number, hardware and firmware versions</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_ID(int hdl,unsigned char* value);

/// <summary>
/// Returns connected filter's wavelength range.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="max">max wavelength </param>
/// <param name="min">min wavelength </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_Specification(int hdl,int* max, int* min);

/// <summary>
/// Returns filter spectrum range and available bandwidth mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="filterSpectrumRange">
/// <p>0000 0001 = Visible</p>
/// <p>0000 0010 = NIR</p>
/// <p>0000 0100 = IR(future model)</p>
/// </param>
/// <param name="availableBandwidthMode">
/// <p>0000 0001 = BLACK</p>
/// <p>0000 0010 = WIDE</p>
/// <p>0000 0100 = MEDIUM</p>
/// <p>0000 1000 = NARROW</p>
/// <p>0001 0000 = SUPER NARROW (future model)</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_OpticalHeadType(int hdl,unsigned char* filterSpectrumRange, unsigned char* availableBandwidthMode);

/// <summary>
/// Sets output mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>1 = manual (PC or front panel control)</p>
/// <p>2 = sequenced, internal clock triggered</p>
/// <p>3 = sequenced, external triggered</p>
/// <p>4 = analog signal controlled,  internal clock triggered</p>
/// <p>5 = analog signal controlled, external triggered</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_OutputMode(int hdl, int value);

/// <summary>
/// Returns the current output mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>1 = manual (PC or front panel control)</p>
/// <p>2 = sequenced, internal clock triggered</p>
/// <p>3 = sequenced, external triggered</p>
/// <p>4 = analog signal controlled,  internal clock triggered</p>
/// <p>5 = analog signal controlled, external triggered</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_OutputMode(int hdl,int* value);

/// <summary>
/// Set bandwidth mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>1 = BLACK mode</p>
/// <p>2 = WIDE mode</p>
/// <p>4 = MEDIUM mode</p>
/// <p>8 = NARROW mode</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_BandwidthMode(int hdl, int value);

/// <summary>
/// Returns the current bandwidth mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>1 = BLACK mode</p>
/// <p>2 = WIDE mode</p>
/// <p>4 = MEDIUM mode</p>
/// <p>8 = NARROW mode</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_BandwidthMode(int hdl,int* value);

/// <summary>
/// Set wavelength.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">wavelength within the available wavelength range</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_Wavelength(int hdl, int value);

/// <summary>
/// Returns the current wavelength.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">wavelength </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_Wavelength(int hdl,int* value);

/// <summary>
/// Set sequence step data.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="index">index</param>
/// <param name="wavelength">wavelength within filter�s range</param>
/// <param name="interval">time interval</param>
/// <param name="bandwidthMode">bandwidth mode</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_SequenceStepData(int hdl, int index, int wavelength, int interval, int bandwidthMode);

/// <summary>
/// Returns one entry out of the sequence wavelength, time interval and bandwidth.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="index">index</param>
/// <param name="wavelength">wavelength within filter�s range</param>
/// <param name="interval">time interval</param>
/// <param name="bandwidthMode">bandwidth mode</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_SequenceStepData(int hdl, int index, int* wavelength, int* interval, int* bandwidthMode);

/// <summary>
/// Returns the entire sequence of wavelength and time interval.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">the entire sequence of wavelength and time interval </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_AllSequenceData(int hdl,unsigned char* value);

/// <summary>
/// Inserts an entry into the current sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="index">index</param>
/// <param name="wavelength">wavelength within filter�s range</param>
/// <param name="interval">time interval</param>
/// <param name="bandwidthMode">bandwidth mode</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_InsertSequenceStep(int hdl, int index, int wavelength, int interval, int bandwidthMode);

/// <summary>
/// Deletes an entry from the current sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">index of sequence step, 0 to delete all sequence</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_DeleteSequenceStep(int hdl, int value);

/// <summary>
/// Set default wavelength for sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">wavelength within the available wavelength range</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_DefaultWavelengthForSequence(int hdl, int value);

/// <summary>
/// Returns the current default wavelength for all elements in sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">current default wavelength for all elements in sequence </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_DefaultWavelengthForSequence(int hdl, int* value);

/// <summary>
/// Set bandwidth mode for all elements in sequence..
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>2 = WIDE mode</p>
/// <p>4 = MEDIUM mode</p>
/// <p>8 = NARROW mode</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_DefaultBandwidthForSequence(int hdl, int value);

/// <summary>
/// Returns the current default Bandwidth Mode for all elements in sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>2 = WIDE mode</p>
/// <p>4 = MEDIUM mode</p>
/// <p>8 = NARROW mode</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_DefaultBandwidthForSequence(int hdl, int* value);

/// <summary>
/// Set default time interval for sequence.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">internal trigger default time between 1ms and 60000ms</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_DefaultTimeIntervalForSequence(int hdl, int value);

/// <summary>
/// Returns the current internal trigger default time.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">current internal trigger default time</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_DefaultTimeIntervalForSequence(int hdl, int* value);

/// <summary>
/// Returns the sequence length.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">sequence length </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_SequenceLength(int hdl, int* value);

/// <summary>
/// Returns current filter status.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>0 = initialization</p>
/// <p>1 = warm up</p>
/// <p>2 = ready</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_Status(int hdl,int* value);

/// <summary>
/// Returns the current filter temperature.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">current filter temperature </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_Temperature(int hdl,double* value);

/// <summary>
/// Set trigger out signal mode.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>0 = normal</p>
/// <p>1 = flipped</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_TriggerOutSignalMode(int hdl, int value);

/// <summary>
/// Returns trigger output mode setting.
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <param name="value">
/// <p>0 = normal</p>
/// <p>1 = flipped</p>
/// </param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Get_TriggerOutSignalMode(int hdl, int* value);


/// <summary>
/// Enforce one step ahead in external triggered sequence mode (Firmware version 3.1 or above).
/// </summary>
/// <param name="hdl">handle of port.</param>
/// <returns> 0: success; negative number: failed.</returns>
COMMANDLIB_API int kurios_Set_ForceTrigger(int hdl);
