from ml import *
from importlib import reload
import lldb
import shlex

def stub_command(debugger, command, result, internal_dict):
    ibp()
    print(debugger)
    print(command)
    print(result)

def lldb_clear(debugger, command, result, internal_dict):
    console.clear()

def lldb_set_watchpoint_common(debugger, read, write, command, result):
    args = shlex.split(command)

    if not args or len(args) > 2:
        result.SetError('invalid args')
        return

    if len(args) == 1:
        args.append('1')

    addr, size = args
    addr, size = int(addr, 16), int(size, 16)

    target = debugger.GetSelectedTarget()

    # print('addr = 0x%x' % addr)
    # print('size = %s' % size)
    # print('read = %s' % read)
    # print('write = %s' % write)
    # print('target = %s %s' % (lldb.target, id(lldb.target)))
    # print('debugger = %s %s' % (debugger, id(debugger)))

    error = lldb.SBError()
    wp = target.WatchAddress(addr, size, read, write, error)

    print(wp)
    if error.fail:
        print('%s' % error)

    # debugger.HandleCommand('watchpoint set expression -w %s -s %s -- %s' % (wp_type, size, addr))

def lldb_set_watchpoint_read(debugger, command, result, internal_dict):
    lldb_set_watchpoint_common(debugger, True, False, command, result)

def lldb_set_watchpoint_write(debugger, command, result, internal_dict):
    lldb_set_watchpoint_common(debugger, False, True, command, result)

def lldb_set_watchpoint_access(debugger, command, result, internal_dict):
    lldb_set_watchpoint_common(debugger, True, True, command, result)

def lldb_set_watchpoint_list(debugger, command, result, internal_dict):
    debugger.HandleCommand('watchpoint list')

def lldb_set_watchpoint_enable(debugger, command, result, internal_dict):
    args = shlex.split(command)
    args = args and str(args[0]) or ''
    debugger.HandleCommand('watchpoint enable %s' % args)

def lldb_set_watchpoint_disable(debugger, command, result, internal_dict):
    args = shlex.split(command)
    args = args and str(args[0]) or ''
    debugger.HandleCommand('watchpoint disable %s' % args)

def lldb_set_watchpoint_delete(debugger, command, result, internal_dict):
    args = shlex.split(command)
    args = args and str(args[0]) or ''
    debugger.HandleCommand('watchpoint delete %s' % args)

def lldb_delete_breakpoint(debugger, command, result, internal_dict):
    args = shlex.split(command)
    args = args and str(args[0]) or '-f'
    debugger.HandleCommand('breakpoint del %s' % args)

def lldb_process_kill(debugger, command, result, internal_dict):
    debugger.HandleCommand('process kill')
    debugger.HandleCommand('target delete --all')

def __lldb_init_module(debugger, internal_dict):
    self = __name__

    cmds = {
        'lldb_clear'                    : 'cls',
        'lldb_set_watchpoint_read'      : 'hr',
        'lldb_set_watchpoint_write'     : 'hw',
        'lldb_set_watchpoint_access'    : 'ha',
        'lldb_set_watchpoint_enable'    : 'he',
        'lldb_set_watchpoint_disable'   : 'hd',
        'lldb_set_watchpoint_delete'    : 'hc',
        'lldb_set_watchpoint_list'      : 'hl',
        'lldb_delete_breakpoint'        : 'bc',
        'lldb_process_kill'             : 'kp',
    }

    for k, v in cmds.items():
        debugger.HandleCommand('command script add -f %s.%s %s' % (self, k, v))
