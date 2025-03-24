<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > 직군관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-10-18 20:08:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
    var auiGridGroup;
    var auiGridMember;

    $(document).ready(function () {
        // aui 생성
        createAUIGridGroup();
        createAUIGridMember();

        goGrpSearch();
    });
    
    function goGrpSearch() {
		var param = {
				
		};
			
		$M.goNextPageAjax(this_page + "/grpSearch", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridGroup, result.list);
				};
			}		
		);	    	
    }
	
    // 그룹 그리드
    function createAUIGridGroup() {

        // 그리드 속성
        var gridPros = {
            rowIdField: "_$uid",
            editable: false,
            showRowNumColumn: true,
            showRowCheckColumn: false,
        };

        // 생성 될 칼럼 레이아웃
        var columnLayout = [
        	{
        		dataField : "code_value",
        		visible : false
        	},
            {
                dataField: "code_name",
                headerText: "그룹명",
                style: "aui-center aui-link"
            },
        ];

        // 그리드 생성
        auiGridGroup = AUIGrid.create("#auiGridGroup", columnLayout, gridPros);

        // 셀 클릭 이벤트
        AUIGrid.bind(auiGridGroup, "cellClick", function(event) {
        	if (event.dataField == "code_name") {
        		// 조직원 조회
        		goMemSearch(event.item.code_value);
        	}
        });
    }
    
    function goMemSearch(jobGrpCd) {
		var param = {
				job_grp_cd : jobGrpCd
		};
			
		$M.goNextPageAjax(this_page + "/memSearch", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridMember, result.list);
					$M.setValue("group_cd", jobGrpCd);
				};
			}		
		);    	
    }
    
    // 맴버 그리드
    function createAUIGridMember() {
        // 그리드 속성
        var gridPros = {
            rowIdField: "_$uid",
            editable: false,
            // 체크박스 표시 설정
            showRowCheckColumn: true,
            // 전체 체크박스 표시 설정
            showRowAllCheckBox: true,
            // 칼럼 상태 표시
            showStateColumn:true,
            // 삭제 예정 설정
            softRemoveRowMode: true,
            // 전체 선택 체크박스가 독립적인 역할을 할지 여부
            independentAllCheckBox: false,
            // 체크박스 설정
//             rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
//                 if (item.eval_yn == 'Y') { // 그룹이 있으면 체크 enable
//                     return false;
//                 }
//                 return true;
//             },
        };

        // 생성 될 칼럼 레이아웃
        var columnLayout = [
            {
                dataField: "mem_no",
                visible: false
            },
            {
                dataField: "job_grp_cd",
                visible: false
            },
            {
                dataField: "org_name",
                headerText: "부서명",
            },
            {
                dataField: "mem_name",
                headerText: "직원명",
            },
            {
                dataField: "removeBtn",
                headerText: "삭제",
                width: "15%",
                renderer: {
                    type: "ButtonRenderer",
                    onClick: function (event) {
                        if (event.item.eval_yn == 'Y') {
                            if (confirm("조직원을 삭제하시겠습니까?") == true) {
                                AUIGrid.removeRow(auiGridMember, event.rowIndex);
                                return;
                            } else {
                                return;
                            }
                        } else {
                            AUIGrid.removeRow(auiGridMember, event.rowIndex);
                        }
                    }
                },
                labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                    return '삭제'
                },
                style: "aui-center",
                editable: false
            }
        ];

        // 그리드 생성
        auiGridMember = AUIGrid.create("#auiGridMember", columnLayout, gridPros);
    }
    
    // 체크 후 삭제
    function fnCheckRemove() {
        AUIGrid.removeCheckedRows(auiGridMember);
    }
	
	function fnClose() {
		window.close();
	}
	
	function goGroupSet() {
		var param = {
				
		}
		var popupOption = "";
		$M.goNextPage('/comm/comm0120p02', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
	// 조직원 추가
	function goAddMemberPopup() {
		if ($M.getValue("group_cd") == "") {
			alert("그룹을 먼저 선택 해 주세요.");
			return false;
		}
		
		var param = {
				"parent_js_name": "modifyMemberGridInfo"
		}
		var popupOption = "";
		$M.goNextPage('/comm/comm0120p03', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
    function modifyMemberGridInfo(memberObj, callback) {
        if ($M.getValue("group_cd") == "") { // 선택한 그룹이 없는데 조직원을 추가할 경우
            callback();
            return;
        }

        var item = {};
        if (memberObj.length != undefined) { // 배열일 경우
            for (var i = 0; i < memberObj.length; i++) {
                if (!(AUIGrid.isUniqueValue(auiGridMember, "mem_no", memberObj[i].mem_no))) { // 같은 직원 중복 체크
                    continue;
                }
                item.mem_no = memberObj[i].mem_no;
                item.mem_name = memberObj[i].mem_name;
                item.org_code = memberObj[i].org_code;
                item.org_name = memberObj[i].org_name;
                AUIGrid.addRow(auiGridMember, item, 'last');
            }
        } else { // 배열이 아닐 경우
            if ((AUIGrid.isUniqueValue(auiGridMember, "mem_no", memberObj.mem_no))) { // 같은 직원 중복 체크
                item.mem_no = memberObj.mem_no;
                item.mem_name = memberObj.mem_name;
                item.org_code = memberObj.org_code;
                item.org_name = memberObj.org_name;
                AUIGrid.addRow(auiGridMember, item, 'last');
            }
        }
    }
    
    // 저장
    function goSave() {
        if (fnChangeGridDataCnt(auiGridMember) == 0) {
            alert("변경사항이 없습니다.");
            return;
        }
        
        var frm = fnChangeGridDataToForm(auiGridMember);
        $M.setValue(frm, "job_grp_cd", $M.getValue("group_cd"));
        if (frm != null) {
    	    $M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'}, function (result) {
    	        if (result.success) {
    	          	goMemSearch($M.getValue("group_cd"));
    	        }
    	    });
        }
    }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
        <div class="row">
            <!-- 그룹 영역 -->
            <div class="col-4">
                <div class="title-wrap">
                    <div class="left">
                        <h4>그룹</h4>
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
                    </div>
                </div>
                <div id="auiGridGroup" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /그룹 영역 -->
            <!-- 조직원 영역 -->
            <div class="col-8">
                <div class="title-wrap">
                    <div class="left">
                        <h4>조직원</h4>
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGridMember" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /조직원 영역 -->
            <!-- 버튼 영역 -->
            <div class="btn-group mt10 mr5">
                <div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /버튼 영역 -->
        </div>
    </div>
</div>
</form>
</body>
</html>