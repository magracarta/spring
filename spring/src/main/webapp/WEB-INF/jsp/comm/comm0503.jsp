<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 결재선관리 > 결재선관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-01-13 15:01:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridLeft;
		var auiGridRight;
		var orgList;
		var apprJobList;
		
		$(document).ready(function() {
			orgList = newObj(orgListJson);
			apprJobList = newObj(apprJobJson);
			createAUIGridLeft();
			createAUIGridRight();
			
		});	
		
		 function newObj(param){
		    return $.extend(true, [], param);
		};
		
		//조회
		function goSearch() { 
			var param = {
					"s_org_code" : $M.getValue("s_org_code"),
					"s_appr_line_name" : $M.getValue("s_appr_line_name")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);
						AUIGrid.clearGridData(auiGridRight);
						$("#total_cnt").html(result.total_cnt);
					}
				;
			});
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = [ "s_org_code", "s_appr_line_name" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}
 		
		// 저장
		function goSave() {
			// 결재선 상세 목록 중복체크
			var distinction = AUIGrid.getColumnDistinctValues(auiGridRight, "org_code");
			var rowItems = '';
			if(distinction.length > 0) {
				for(i = 0; i < distinction.length; i++) {
					rowItems = AUIGrid.getItemsByValue(auiGridRight, "org_code", distinction[i]);
					for(j = 0; j < rowItems.length; j++) {
						for(k = 0; k < j; k++) {
							if(rowItems[j].appr_job_cd == rowItems[k].appr_job_cd) {
								if(j == k) {	
									continue;	
								} else {
									alert("동일한 결재선이 있습니다.");
									return false;
								}
								
							}
						}
					}
				}
			}
			if (fnChangeGridDataCnt(auiGridRight) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var param = {
	                "appr_line_seq" : $M.getValue("appr_line_seq")
			}; 
			if(isValid()) {
				var frm = fnChangeGridDataToForm(auiGridRight);
				$M.goNextPageAjaxSave(this_page + "/" + param.appr_line_seq + "/save", frm, {method : 'POST'}, 
					function(result) {
						if(result.success) {
							AUIGrid.removeSoftRows(auiGridRight);
							AUIGrid.resetUpdatedItems(auiGridRight);
							resetOrgList();
						};
					}
				);
			}
		}
		
		// 결재선 목록 그리드
		function createAUIGridLeft() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "appr_line_seq",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				fillColumnSizeMode : false,
				height : "420",
				headerHeight : 50
			};
			var columnLayout = [ 
				{
					headerText : "결재타입",
					dataField : "appr_line_name",
					width : "20%",
					style : "aui-left",
					editable : false
				}, {
					headerText : "결재단계",
					dataField : "appr_level",
					width : "65%",
					style : "aui-left aui-link",
					editable : false
				}, {
					headerText : "전결여부",
					dataField : "writer_appr_yn",
					width : "10%",
					style : "aui-center",
					editable : false
				}, {
					headerText : "결재라인<br> 수정여부",
					dataField : "line_modify_yn",
					width : "10%",
					style : "aui-center",
					editable : false 
				}, {
					headerText : "최종결재자<br> 지정여부",
					dataField : "last_appr_mem_yn",
					width : "12%",
					style : "aui-center",
					editable : false
				}, {
					headerText : "결재 메뉴 수",
					dataField : "appr_job_cnt",
					width : "10%",
					style : "aui-center",
					editable : false
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				var frm = document.main_form;
				$M.setValue(frm,'appr_line_seq', event.item['appr_line_seq']);
				var param = {
					"appr_line_seq" : event.item["appr_line_seq"]
				};
				goSearchDetail(param);
			});
		}

		//그리드셀 클릭시
		function goSearchDetail(param) {
			//param값 없으면 return
			if (param == null) {
				return;
			}
			$M.goNextPageAjax(this_page + "/" + param.appr_line_seq, '', '', 
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGridRight, result.list);
						resetOrgList();
					}
			});
		}

		// 결재선 상세 목록 그리드
		function createAUIGridRight() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "_$uid",
					// rowIdField가 unique 임을 보장
					rowIdTrustMode : true,
					// rowNumber 
					showRowNumColumn : true,
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// 행 소프트 제거 모드 해제
					softRemoveRowMode : true,
					fillColumnSizeMode : false,
					showFooter : false,
					editable : true,
					
			};
			var myEditRenderer = {
					type : "DropDownListRenderer",
					keyField : "org_code",
					valueField  : "org_name",
					showEditorBtnOver : true,
					listFunction : function(rowIndex, columnIndex, item, dataField) {
						// orgList 가공을 위한 메소드
						duplicationOrgList();
						return orgList;
					}
					
			};
			var myEditRenderer2 = {
						type : "DropDownListRenderer",
						keyField : "code",
						valueField  : "code_name",
						showEditorBtnOver : true,
						listFunction : function(rowIndex, columnIndex, item, dataField) {
							// apprJobList 가공을 위한 메소드
							duplicationApprJobList(item.org_code);
							return apprJobList;
						}
					
			};
			var columnLayout = [
				{
					headerText : "부서",
					dataField : "org_code",
					width : "30%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								return myEditRenderer;
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var i = 0, len = orgListJson.length; i < len; i++) {
							if(orgListJson[i]["org_code"] == value) {
								retStr = orgListJson[i]["org_name"];
								break;
							}
						}
						return retStr;
					},
				},
				{
					headerText : "결재 메뉴",
					dataField : "appr_job_cd",
					width : "55%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								return myEditRenderer2;
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) { 
						var retStr = value;
						for(var i = 0, len = apprJobJson.length; i < len; i++) {
							if(apprJobJson[i]["code"] == value) {
								retStr = apprJobJson[i]["code_name"];
								break;
							}
						}
						return retStr;
					},
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "15%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							console.log(isRemoved, "isRemoved");
							if(isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			AUIGrid.bind(auiGridRight, "cellEditBegin", function(event) {
				var rowIdField = AUIGrid.getProp(auiGridRight, "rowIdField");
				if(AUIGrid.isAddedById(auiGridRight, event.item[rowIdField])) {
		            return true;
			    }
			    return false; 
			});
		}
		
		// orgList의 길이 초기화
		function resetOrgList() {
			duplicationOrgList();
		}
		
		function duplicationOrgList() {
			orgList = newObj(orgListJson);
			var params = AUIGrid.getGridData(auiGridRight);
			var org_code = [];
			var appr_job = [];
			// 기존 데이터 배열에 담기
			for(var i = 0; i < params.length; i++) {
				org_code.push(params[i].org_code);
				appr_job.push(params[i].appr_job_cd);
			}
			// 부서 리스트
			for(var i = orgList.length - 1; i >= 0; i--) {
				var count = 0;
				for(var j = 0; j < org_code.length; j++){
					if(orgList[i].org_code == org_code[j]) {
						count++;
						if(count == apprJobJson.length) {
							orgList.splice(i, 1);
							break;
						}
					}
				}
				
			}
			return orgList;
		}
		
		
		function duplicationApprJobList(newOrgCode) {
			apprJobList = newObj(apprJobJson);
			var params = AUIGrid.getGridData(auiGridRight); // auiGridRight 그리드의 값
			var org_code = []; // 기존 부서 목록
			var appr_job = []; // 기존 결재 메뉴 목록
			var tempAppr = [];	// 클릭한 org_code값의 해당하는 기존 결재 메뉴 데이터를 담을 배열
			// 기존 데이터 배열에 담기
			for(var i = 0; i < params.length; i++) {
				org_code.push(params[i].org_code);
				appr_job.push(params[i].appr_job_cd);
			}
			// 기존 부서 데이터(org_code)와 드랍다운 리스트에서 클릭한 org_code(newOrgCode)가 같은 데이터 중
			// null이 아닌 결재 메뉴(appr_job)의 값을 temp에 넣어줌
			for(var i = 0; i < org_code.length; i++) {
				if(org_code[i] == newOrgCode) {
					if(appr_job[i] != '') {
						tempAppr.push(appr_job[i]);
					}
				}
			}
			// 해당 부서의 이미 존재하는 결재 메뉴 제거
			for(var i = 0; i < tempAppr.length; i++) {
				for(var j = 0; j < apprJobList.length; j++) {
					if(tempAppr[i] == apprJobList[j].code) {
						apprJobList.splice(j, 1);
					}
				}
			}
			// orgList의 길이 초기화
			for(var i = orgList.length - 1; i >= 0; i--) {
				var count = 0;
				for(var j = 0; j < org_code.length; j++){
					if(orgList[i].org_code == org_code[j]) {
						count++;
						if(count == apprJobJson.length) {
							orgList.splice(i, 1);
							break;
						}
					}
				}
				
			}
			return apprJobList;
		}
		
		//그리드 행추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridRight, "org_code");
			fnSetCellFocus(auiGridRight, colIndex, "org_code");
			var row = new Object();
			if(isValid()) {
				if(orgList.length > 0) {
					row.org_code = '';
					row.appr_job_cd = '';
					row.removeBtn = '삭제';
					AUIGrid.addRow(auiGridRight, row, "last");
				} else {
					alert("추가할 결재선이 없습니다.");
				}
			}
		}
		
		// 그리드 빈값 체크
		function isValid() {
			return AUIGrid.validateGridData(auiGridRight, ["org_code", "appr_job_cd"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<!--  <input type="hidden" id="cmd" name="cmd" value="C"> -->
	<input type="hidden" id="appr_line_seq" name="appr_line_seq">
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="130px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>	
								<th>부서</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${list}" var="item">
											  <option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>결재타입</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" id="s_appr_line_name" name="s_appr_line_name" class="form-control">
										</div>
									</td>						
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->	
<!-- 하단 폼테이블 -->		
			<div class="row">					
<!-- 좌측 폼테이블 -->
				<div class="col-7">
<!-- 결재선 목록 -->
					<div class="title-wrap mt10">
						<h4>결재선 목록</h4>
						
					</div>
					<div id="auiGridLeft" style="margin-top: 5px; height: 420px;">
					</div>
					<div class="btn-group mt5">
						<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건 
							</div>						
						</div>
<!-- /결재선 목록 -->
				</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
				<div class="col-5">
<!-- 결재선 상세 목록 -->
					<div class="title-wrap mt10">
						<h4>결재선 상세 목록</h4>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridRight" style="margin-top: 5px; height: 420px;">
					</div>
<!-- /결재선 상세 목록 -->

				</div>
<!-- /우측 폼테이블 -->
			</div>
<!-- /하단 폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
							</div>	
						</div>
							<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
					</div>
<!-- /contents 전체 영역 -->
				</div>
</form>
</body>
</html>