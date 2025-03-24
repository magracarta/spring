<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 지출결의서 > null > 지출결의서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;
	
	// 사용구분
	var docExpensePayJson = JSON.parse('${codeMapJsonObj['DOC_EXPENSE_PAY']}');
	
	var regMemNo = '${info.mem_no}';
	var memNo = '${SecureUser.mem_no}';
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
		
		// 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y'))
	    ) {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :checkbox").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
		}
		
	    if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y') {
			$("#_fnPrint").show();
		} else {
			$("#_fnPrint").hide();
		}
	});
	
	// 첨부파일
	function goSearchFile(){
		if($("input[class='doc_file_list']").size() >= fileMaxCount) {
			alert("파일은 " + fileMaxCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
        var param = {
            upload_type: 'DOC',
            file_type: 'both',
        };
        
		openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
	}
	
	function fnPrintFileInfo(result) {
		setFileInfo(result.file_seq, result.file_name)
	}
	
	//첨부파일 세팅
	function setFileInfo(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" class="doc_file_list" name="doc_file_seq_'+ fileIndex + '" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) { 
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
			$("#doc_file_seq_" + fileIndex).remove();
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
				dataField : "seq_no",
				visible : false
			},
			{
				headerText: "사용구분",
				dataField: "doc_expense_pay_cd",
				width : "120",
				style : "aui-center",
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
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "적요",
				dataField: "remark",
				width : "370",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "금액",
				dataField: "expense_amt",
				width : "140",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if ((($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
							       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y'))) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							}
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
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			// 결재상태에 따라 에디팅 제어
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02017_001}' == 'Y') {
				if (event.dataField) {
					return true;
				}
			}
			
			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo)) {
				if (event.dataField) {
					return false;
				}
			}
		});
	}
	
	// 행추가
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.doc_expense_pay_cd = "",
    		item.remark = "",
    		item.seq_no = "",
    		item.expense_amt = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}	
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["doc_expense_pay_cd", "remark", "expense_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 결재취소
	function goApprCancel() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}",
			appr_cancel_yn: "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method: 'GET'},
			function (result) {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}
	
	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}"
		};
		$M.setValue("save_mode", "approval"); // 승인
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResult(result) {
		// 반려이면 페이지 리로딩
		if (result.appr_status_cd == '03') {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("반려가 완료되었습니다.");
						location.reload();
					}
				}
			);
		} else if (result.appr_status_cd == '05') {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
					function (result) {
						if (result.success) {
							alert("종결처리가 완료되었습니다.");
							location.reload();
						}
					}
			);
		} else {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			);
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

	// 종결처리
	function goApprovalEnd() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_end_only : 'Y',
		};
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	// 수정
	function goModify(isRequestAppr) {
		// validationcheck
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if (fnCheckGridEmpty() == false) {
			return;
		};

		var idx = 1;
		$("input[class='doc_file_list']").each(function() {
			var str = 'doc_file_seq_' + idx;
			$M.setValue(str, $(this).val());
			idx++;
		});
		
		for(; idx <= fileMaxCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, 0);
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
		}
		
		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGrid);
		$M.copyForm(gridFrm, frm);

		console.log(gridFrm);

		$M.goNextPageAjaxMsg(msg, this_page + "/modify", gridFrm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
					window.location.reload();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);
		
		var concatCols = [];
		var concatList = [];
		var gridIds = [auiGrid];
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		
		console.log("gridFrm : ", gridFrm);

		$M.goNextPageAjaxRemove(this_page + "/remove", gridFrm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
	    			fnClose();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}	
	
	function fnClose() {
		window.close();
	}
	
	
	// 인쇄
	function fnPrint() {
		
		var apprListJson = JSON.parse('${apprMemoListJson}');
		var apprMemoListJson = [];
		for(var i=0; i<apprListJson.length; i++){
			apprMemoListJson.push(apprListJson[i]);
			if(apprListJson[i].appr_status_cd == '03'){
				apprMemoListJson = [];
			}
		}
		
		apprMemoListJson[0].grade_name = "작성자";
		
 		// 상세내역
		var gridData = AUIGrid.getGridData(auiGrid);
		
		var data = {
			"mem_name" : "${info.mem_name}"
			, "doc_dt" : "${info.doc_dt}"
			, "org_name" : "${info.org_name}"
			, "grade_name" : "${info.grade_name}"
			, "expense_dt" : $M.getValue("expense_dt")
			, "title" : $M.getValue("title")
			, "add_memo" : $M.getValue("add_memo")
		};
		
		var param = {
			"data" : data
			, "dtlData" : gridData
			, "apprData" : apprMemoListJson
		}
		
		openReportPanel("mmyy/mmyy011104p01_01.crf", param);
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}" />
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div class="text-right">
	                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
	            </div>
				<!-- 폼테이블 -->
				<div class="title-wrap mt10">
					<div class="left approval-left">
						<h4 class="primary">지출결의서 상세</h4>
					</div>
					<!-- 결재영역 -->
					<div class="pl10">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">작성자</th>
							<td><input type="text" class="form-control width120px"
								readonly value="${info.mem_name}"> <input type="hidden"
								id="mem_no" name="mem_no" value="${info.mem_no}"></td>
							<th class="text-right">작성일</th>
							<td><input type="text" class="form-control width120px"
								readonly id="doc_dt" name="doc_dt" value="${info.doc_dt}"
								dateformat="yyyy-MM-dd"></td>
						</tr>
						<tr>
							<th class="text-right">부서</th>
							<td><input type="text" class="form-control width120px"
								readonly value="${info.org_name}"> <input type="hidden"
								id="org_code" name="org_code" value="${info.org_code}">
							</td>
							<th class="text-right">직위</th>
							<td><input type="text" class="form-control width120px"
								readonly value="${info.grade_name}"> <input
								type="hidden" id="grade_cd" name="grade_cd"
								value="${info.grade_cd}"> <input type="hidden"
								id="job_cd" name="job_cd" value="${info.job_cd}"></td>
						</tr>
						<tr>
							<th class="text-right essential-item">지출일</th>
							<td colspan="3">
								<div class="input-group width120px">
									<input type="text"
										class="form-control border-right-0 rb width100px calDate"
										id="expense_dt" name="expense_dt" dateformat="yyyy-MM-dd"
										alt="지출일" required="required" value="${info.expense_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td colspan="3"><input type="text"
								class="form-control rb" alt="제목" id="title"
								name="title" required="required" value="${info.title}">
							</td>
						</tr>
					</tbody>
				</table>
				<!-- /폼테이블 -->
				<!-- 지출상세내역 -->
				<div class="title-wrap mt10">
					<h4>지출상세내역</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
							name="pos" value="MID_R" /></jsp:include>
				</div>
				<div id="auiGrid" class="width750px"
					style="margin-top: 5px; height: 200px;"></div>
				<!-- /지출상세내역 -->

				<div class="title-wrap mt10">
					<h4>추가의견</h4>
				</div>
				<div>
					<textarea class="form-control" style="height: 100px;" id="add_memo" name="add_memo" maxlength="100">${info.add_memo}</textarea>
				</div>

				<!-- 폼테이블 -->
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">첨부파일</th>
							<td>
								<div class="table-attfile doc_file_div" style="width: 100%;">
									<div class="table-attfile" style="float: left">
										<button type="button" class="btn btn-primary-gra mr10"
											name="fileAddBtn" id="fileAddBtn"
											onclick="javascript:goSearchFile();">파일찾기</button>
										&nbsp;&nbsp;
									</div>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<!-- /폼테이블 -->
				<!-- 하단 내용 -->
				<div class="doc-com ">
					<div class="text">
						위 금액을 영수(청구)합니다.<br> ${info.apply_date.substring(0,4)}년
						${info.apply_date.substring(4,6)}월 ${info.apply_date.substring(6,8)}일
					</div>
					<div class="detail-info">
						부서 : ${info.org_name}<br> 성명 : ${info.mem_name}
					</div>
				</div>
				<!-- /하단 내용 -->
				<!-- 결재자 의견 -->
				<div class="title-wrap mt10">
					<div class="left">
						<h4>결재자 의견</h4>
					</div>
				</div>
				<table class="table mt5">
					<colgroup>
						<col width="40px">
						<col width="">
						<col width="60px">
						<col width="">
					</colgroup>
					<thead>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container"
									style="width: 100%; height: 110px;">
									<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
												<col width="">
											</colgroup>
											<thead>
												<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
												<tr>
													<th class="th" style="font-size: 12px !important">구분</th>
													<th class="th" style="font-size: 12px !important">결재일시</th>
													<th class="th" style="font-size: 12px !important">담당자</th>
													<th class="th" style="font-size: 12px !important">특이사항</th>
												</tr>
											</thead>
											<tbody>
												<c:forEach var="list" items="${apprMemoList}">
													<tr>
														<td class="td"
															style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
														<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
														<td class="td"
															style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
														<td class="td" style="font-size: 12px !important">${list.memo }</td>
													</tr>
												</c:forEach>
											</tbody>
										</table>
									</div>
								</div>
							</td>
						</tr>

						</tbody>
				</table>
<!-- /결재자 의견 -->
			<div class="btn-group mt10">
				<div class="right">
					<!-- 관리부는 수정가능 -->
					<c:if test="${page.fnc.F02017_001 eq 'Y' and info.appr_proc_status_cd == '05'}">
						<button type="button" class="btn btn-info" id="_goModify" name="_goModify" onclick="javascript:goModify()">수정</button>
					</c:if>			
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /><jsp:param name="appr_yn" value="Y" /></jsp:include>
				</div>
			</div>
        
					</div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1"
			value="${info.doc_file_seq_1 }" />
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2"
			value="${info.doc_file_seq_2 }" />
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3"
			value="${info.doc_file_seq_3 }" />
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4"
			value="${info.doc_file_seq_4 }" />
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5"
			value="${info.doc_file_seq_5 }" />	
</form>
</body>
</html>