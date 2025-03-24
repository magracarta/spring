<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 코드관리 > null > null
-- 작성자 : 강명지
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var comboGridSample;
		
		$(document).ready(function() {
			createAUIGrid();
			fnNew();
			$("#code").bind("keyup",function(){
				$(this).val().toUpperCase();
		 	});
		});
		function checkCode() {
			var regExp =  /^[A-Za-z0-9_+]*$/;
			if( regExp.test($M.getValue("code")) ||  $M.getValue("code") == "---") {
				return true;
			}
			$M.setValue("code","");
			alert("코드 형식이 올바르지 않습니다.");
			$("#code").focus();
			return false;
		}
			
		//조회
		function goSearch() { 
			fnNew();
			var param = {
					"s_group_code" : $M.getValue("s_group_code"),
					"s_use_yn" : $M.getValue("s_use_yn"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.expandAll(auiGrid);
					}
				}
			);
		}
		
		//저장
		function goSave(frm) {
			var frm = document.main_form;
			if($M.validation(frm) == false) { return;}
			if($M.getValue('group_code') == '') {
				alert("그룹코드를 선택해주세요.");
				$M.setValue("code", "");
				return;
			} 
			if(checkCode() == false) {	return;	}
			
			var cmd = $M.getValue(frm, "cmd");
			if("U" == cmd) {
				$M.setValue(frm, "cmd", "U");	
				goUpdate(frm);
			} else if("C" == cmd){
				$M.goNextPageAjaxSave(this_page, frm , {method : 'POST'},
					function(result) {
			    		if(result.success) {
							fnNew();
							goSearch();
						}
					}
				);
			}
		}
		
		//수정
		function goUpdate(frm){
			$M.goNextPageAjaxSave(this_page + "/" + $M.getValue("group_code") + "/" + $M.getValue("code"), frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
						fnNew();
						goSearch();
					}
				}
			);
		 	fnStateChange(true);
		}
		
		function fnStateChange(disabled) {
			var isDisabled = disabled == true ? 'disable' : 'enable';
			$('#group_code').combogrid(isDisabled);
			$("#group_code").attr("disabled", disabled);
			$("#code").attr("disabled", disabled);
		}
		
		//신규 (초기화)
		function fnNew() {
			AUIGrid.clearSelection(auiGrid);
			fnStateChange(false);
			$M.setValue(document.main_form, "cmd", "C");
			
			//정보 초기화
			$M.clearValue({field : ["code", "code_name", "sort_no", "code_desc", "bigo", "code_v1", "code_v2", "code_v3", "code_v4", "code_v5", "code_v6", "code_v7", "code_v8", "code_v9", "code_10"]});

			$M.setValue("group_code", "");
			$("#code").attr("class", 'form-control essential-bg');
			$("#group_code").attr("class", 'form-control essential-bg');
			$M.setValue("show_yn", "Y");
			$M.setValue("use_yn", "Y");
			$M.setValue("group_code", '');
			$("#after_menu_push").prop('checked', true);
		}
		
		//그룹 코드 체인지 액션
		function fnGroupCodeChangeAction(obj) {
			var newValue = $M.getValue(obj);
		
			if(newValue == 'Y'){
				$M.setValue("group_code", "");
				$("#group_code").attr("disabled", true);
			} else if(newValue == 'N'){
				$("#group_code").attr("disabled", false);
			}
			fnGroupCodeChange();
		}
		
		//왼쪽 그리드 클릭시 상세 정보 조회
		function goSearchDetail(param) {
			$M.goNextPageAjax(this_page +"/"+ param.s_group_code + "/" + param.s_code, '', '',
				function(result) {
					if(result.success) {
						// $('#group_code').combogrid('grid').datagrid('load',{q:''})
						var detail = result.detail;
						for(var key in detail) {
							$M.setValue(key, detail[key]);
						}
						$M.setValue("group_code", detail['group_code']);
						$M.setValue("use_yn", detail['use_yn']);
						$M.setValue("show_yn", detail['show_yn']);
						fnStateChange(true);
					}
				}
			);
		}
		
		//그룹코드가 수정될때
		function fnGroupCodeChange() {
			$M.clearValue({field : ["code", "code_name", "sort_no", "code_desc", "bigo", "code_v1", "code_v2", "code_v3", "code_v4", "code_v5", "code_v6", "code_v7", "code_v8", "code_v9", "code_v10"]});
		}
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				//확인필요
				rowIdField : "_$uid",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				width : 420, 
		        enableFilter :true,
			};
			var columnLayout = [

				{ 
					headerText : "코드명", 
					dataField : "code_name", 
					style : "aui-left aui-link",
					editable : false,
					filter : {
		                  showIcon : true,
		            },
				},
				{ 
					headerText : "코드", 
					dataField : "code", 
					style : "aui-center",
					editable : false,
					filter : {
		                  showIcon : true,
		            },
		            width : "15%"
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					style : "aui-center",
					editable : false,
					filter : {
		                  showIcon : true,
		            },
		            width : "25%",
				},
				{ 
					headerText : "순서", 
					dataField : "sort_no", 
					style : "aui-center",
					editable : false,
					filter : {
		                  showIcon : true,
		            },
		            width : "20%"
				}
			]
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				fnNew();
				var frm = document.main_form;
				$M.setValue(frm, "cmd", "U");
				$("#group_code").attr('class', 'readonly');
				//$("#code").attr('class', 'readonly');
				var param = {
						"s_group_code" : event.item["group_code"],
						"s_code" : event.item["code"]
				}
				goSearchDetail(param); 
			});
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="cmd" name="cmd" value="C">
<!-- contents 전체 영역 -->
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
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>							
									<th>그룹코드</th>
									<td>
										<input type="text" style="width : 320px";
											id="s_group_code" 
											name="s_group_code" 
											easyui="combogrid"
											header="Y"
											easyuiname="groupCode" 
											panelwidth="500"
											maxheight="300"
											textfield="code_name"
											multi="N"
											enter="goSearch()"
											idfield="group_code" />
										<%-- <select class="form-control" id="s_group_code" name="s_group_code" style="width:200px;">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${list}">
												<option value="${item.group_code}" >${item.code_name}</option>
											</c:forEach>
										</select> --%>
									</td>
									<th>사용여부</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="">- 전체 -</option>
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->	
					<div class="row">
<!-- 코드목록 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>코드목록</h4>
								<div class="btn-group">
									<div class="right">
										<button type="button" class="btn btn-default" onclick=AUIGrid.expandAll(auiGrid);><i class="material-iconsadd text-default"></i>전체펼치기</button>
										<button type="button" class="btn btn-default" onclick=AUIGrid.collapseAll(auiGrid);><i class="material-iconsremove text-default"></i>전체접기</button>
									</div>
								</div>						
							</div>
							<div id="auiGrid" style="margin-top: 5px; height: 87%"></div>
						</div>
<!-- /코드목록 -->						
						<div class="col-8">
							<div class="row">
<!-- 코드정보 -->								
								<div class="col-12">
									<div class="title-wrap mt10">
										<h4>코드정보</h4>					
									</div>									
<!-- 폼테이블 -->	
									<div>
										<table class="table-border">
											<colgroup>
												<col width="100px">
												<col width="">
												<col width="100px">
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">그룹코드</th>
													<td colspan="3">
														<div class="col-12">
															<input type="text" style="width : 320px";
															id="group_code" 
															name="group_code" 
															easyui="combogrid"
															header="Y"
															easyuiname="groupCode" 
															panelwidth="500"
															maxheight="155"
															textfield="code_name"
															multi="N"
															idfield="group_code" />
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N">
															<label class="form-check-label">N</label>
														</div>
													</td>	
													<th class="text-right essential-item">시스템노출여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="show_yn" value="Y">
															<label class="form-check-label">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="show_yn" value="N">
															<label class="form-check-label">N</label>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">코드</th>
													<td>
														<input type="text" class="form-control essential-bg" id="code" name="code" required="required"> 
													</td>
													<th class="text-right essential-item">코드명</th>
													<td>
														<input type="text" class="form-control essential-bg" id="code_name" name="code_name" required="required">
													</td>
												</tr>
												
												<tr>
													<th class="text-right essential-item">순서</th>
													<td>
														<input type="text" class="form-control essential-bg" id="sort_no" format="decimal" name="sort_no" alt="순서" required="required">
													</td>
													<td colspan="2">
														<input type="checkbox" id="after_menu_push" name="after_menu_push" checked="checked"><label for="after_menu_push">후순위 메뉴 밀기</label>
													</td>
												</tr>
												<tr>
													<th class="text-right">코드설명</th>
													<td colspan="3">
														<textarea class="form-control" style="height: 50px;" id="code_desc" name="code_desc"></textarea>
													</td>
												</tr>
												<tr>
													<th class="text-right">비고</th>
													<td colspan="3">
														<textarea class="form-control" style="height: 50px;" id="bigo" name="bigo"></textarea>
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성1</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v1" name="code_v1">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성2</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v2" name="code_v2">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성3</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v3" name="code_v3">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성4</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v4" name="code_v4">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성5</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v5" name="code_v5">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성6</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v6" name="code_v6">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성7</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v7" name="code_v7">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성8</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v8" name="code_v8">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성9</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v9" name="code_v9">
													</td>
												</tr>
												<tr>
													<th class="text-right">코드속성10</th>
													<td colspan="3">
														<input type="text" class="form-control" id="code_v10" name="code_v10">
													</td>
												</tr>
											</tbody>
										</table>
									</div>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
<!-- /코드정보 -->									
							</div>					
						</div>
					</div>
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</form>	
</body>
</html>