
routine-level on error undo, throw.

using Progress.Lang.*.
using com.quarix.data.DataAccess.

&global-define tbl_item Item

class wicketds.server.daitem inherits DataAccess:

    {wicketds/server/dsitem.i}

    define buffer {&tbl_item} for {&tbl_item}.

    constructor public daitem (  ):
        ID = 'daitem':u.
    end constructor.

    method private character SetFieldMappings():

        define variable cFieldMapping as character no-undo.

        assign
            cFieldMapping   =
                '{&tbl_item}.Itemnum'         + ',ttitem.Itemnum'   + ',' +
                '{&tbl_item}.Price'           + ',ttitem.Price'      + ',' +
                '{&tbl_item}.CatDescription'  + ',ttitem.CatDescription'      + ',' +
                '{&tbl_item}.ItemName'        + ',ttitem.ItemName'      + ',' +
                '{&tbl_item}.Weight'          + ',ttitem.Weight'      + ',' +
                '{&tbl_item}.Category1'        + ',ttitem.Category1'      + ',' +
                '{&tbl_item}.Category2'        + ',ttitem.Category2'
                .
        return cFieldMapping.

    end method.

    method private logical AttachDataSourceDefault():

        define variable cFieldMapping   as character    no-undo.
        define variable cDbTables       as character    no-undo.
        define variable cKeys           as character    no-undo.

        cFieldMapping = SetFieldMappings().

        assign
            cDbTables   = "{&tbl_item}"
            cKeys       = 'Itemnum':U.

        return AddDataSource ('ttitem':u, cDbTables, cKeys, ?, cFieldMapping).

        catch appError as Progress.Lang.Error :
            ThrowError(input appError).
            delete object appError.
            return false.
        end catch.

    end method.

    method private logical AttachDataSourceIdList():

		define variable hTmpList       as handle    no-undo.
		define variable cJoinClause    as character	no-undo.
		define variable cKeys          as character	no-undo.
		define variable cFieldMapping  as character	no-undo.
		define variable cDbTables      as character	no-undo.
		define variable cExcludeFields as character	no-undo.

		hTmpList = GetIdListTmpHandle().

		if not valid-handle(hTmpList)
		then return false.

		assign
			cKeys			= 'Itemnum':U
			cExcludeFields	= 'ttitem.Itemnum':U.

		if not AddDataSource ('ttitem':u, hTmpList:default-buffer-handle, cKeys, ?, ?, cExcludeFields, ?, ?)
		then return false.

		cFieldMapping = SetFieldMappings().

		assign
            cDbTables   = "{&tbl_item}"
            cKeys       = 'Itemnum':U.

		cJoinClause	= 'ttitem.Itemnum = ttitemidlist.Itemnum':U.

		if not AddDataSource ('ttitem':u, cDbTables, cKeys, ?, cFieldMapping, cExcludeFields, ?, cJoinClause)
		then return false.

		return true.

		catch appError as Progress.Lang.Error :
			ThrowError(input appError).
			delete object appError.
			return false.
		end catch.

	end method.

    method public override logical AttachDataSource():

		define variable cQueryName as character no-undo.

		cQueryName = GetQueryName().

		case cQueryName:

			when 'FetchDataByIdList':U
			then return AttachDataSourceIdList().

			otherwise
				return AttachDataSourceDefault().

		end case.  /* case cQueryName */

		return false.

		catch appError as Progress.Lang.Error :
			ThrowError(input appError).
			delete object appError.
			return false.
		end catch.

	end method.

    method private logical BeforeSaveData(input-output dataset dsitem):

        for each ttitem
            where row-state(ttitem) = row-created
            no-lock:

            ttitem.Itemnum = next-value(NextItemNum).
        end.

        return true.

        catch appError as Progress.Lang.Error :
            ThrowError(input appError).
            delete object appError.
            return false.
        end catch.

    end method.

    method public override logical BeforeSaveData():
        return BeforeSaveData(input-output dataset-handle datasetHandle by-reference).
    end method.

end class.