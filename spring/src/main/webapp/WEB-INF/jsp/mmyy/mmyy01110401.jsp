<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 지출결의서 > 지출결의서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 사용구분
	var docExpensePayJson = JSON.parse('${codeMapJsonObj['DOC_EXPENSE_PAY']}');

	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 5;
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
	});
	
	function fnAddFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
		var param = {
			upload_type	: "DOC",
			file_type : "both",
		};
		
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		
	}
	
	function setFileInfo(result) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
		} else {
			return false;
		}
		
	}
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true,
            showFooter : true,
            footerPosition : "top",
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText: "사용구분",
				dataField: "doc_expense_pay_cd",
				width : "120",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : docExpensePayJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<docExpensePayJson.length; i++){
						if(value == docExpensePayJson[i].code_value){
							return docExpensePayJson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "적요",
				dataField: "remark",
				width : "370",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "금액",
				dataField: "expense_amt",
				width : "140",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				editable : true,
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : true
			}
		];

        // 푸터레이아웃
        var footerColumnLayout = [
            {
                labelText : "합계",
                positionField : "remark",
                style : "aui-center aui-footer",
            },
            {
                dataField : "expense_amt",
                positionField : "expense_amt",
                operation : "SUM",
                formatString : "#,##0",
                style : "aui-right aui-footer",
            },
        ];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
        AUIGrid.setFooter(auiGrid, footerColumnLayout);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
	}
	
	
	// 행추가
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.doc_expense_pay_cd = "",
    		item.remark = "",
    		item.expense_amt = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}	
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["doc_expense_pay_cd", "remark", "expense_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if (fnCheckGridEmpty() == false) {
			return;
		};

		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}

        if (confirm(msg) == false) {
            return false;
        }

		var idx = 1;
		$("input[name='file_seq']").each(function() {
			var str = 'doc_file_seq_' + idx;
            if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                $M.setValue(str, $(this).val());
            }
			idx++;
		});

		for(; idx <= fileCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, '');
		}

		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGrid);
		$M.copyForm(gridFrm, frm);

		console.log(gridFrm);
		
		$M.goNextPageAjax(this_page + "/save", gridFrm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}
	
	// 목록
	function fnList() {
// 		history.back();
		
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011104", $M.toGetParam(param));
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail width780px">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
						<h2>지출결의서 등록</h2>
                    </div>
<!-- 결재영역 -->
                    <div class="pl10">
                    	<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                    </div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
                    <table class="table-border width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">작성자</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.kor_name}">
                                    <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                                </td>		
                                <th class="text-right">작성일</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name" value="${info.org_name}">
                                    <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                                </td>		
                                <th class="text-right">직위</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
                                    <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                                    <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">지출일</th>
                                <td colspan="3">
                                    <div class="input-group width120px">
                                        <input type="text" class="form-control border-right-0 essential-bg width100px calDate" id="expense_dt" name="expense_dt" dateformat="yyyy-MM-dd" alt="지출일" required="required" value="${inputParam.s_current_dt}">
                                    </div>
                                </td>						
                            </tr>
                            <tr>
                                <th class="text-right essential-item">제목</th>
                                <td colspan="3">
                                    <input type="text" class="form-control essential-bg" alt="제목" id="title" name="title" required="required">
                                </td>						
                            </tr>					
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 지출상세내역 -->		
                    <div class="title-wrap mt10 width750px">
                        <h4>지출상세내역</h4>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                    </div>	
                    <div id="auiGrid" class="width750px" style="margin-top: 5px; height: 200px;"></div>						
<!-- /지출상세내역 -->

                    <div class="title-wrap mt10 width750px">
                        <h4>추가의견</h4>
                    </div>
                    <div>
                        <textarea class="form-control width750px" style="height: 100px;" id="add_memo" name="add_memo" maxlength="100">${info.add_memo}</textarea>
                    </div>

                    <!-- 폼테이블 -->
                    <table class="table-border mt10 width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">첨부파일</th>
								<td colspan="5">
									<div class="table-attfile doc_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
										&nbsp;&nbsp;
										</div>
									</div>
								</td>							
                            </tr>			
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="doc-com width750px">
                        <div class="text">
                            위 금액을 영수(청구)합니다.<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : ${info.org_name}<br>
                            성명 : ${info.kor_name}
                        </div> 
                    </div>			
<!-- /하단 내용 -->
					<div class="btn-group mt10 width750px">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value=""/>
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value=""/>
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value=""/>
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value=""/>
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value=""/>
</form>	
</body>
</html>